#!/usr/bin/env bash
# Hook PreToolUse: impide modificar el repositorio estando parado en `main`.
#
# Cada unidad de trabajo arranca en su propia rama (ver AGENTS.md). Esta es la
# barrera que lo hace cumplir: una regla escrita depende de que el agente la
# recuerde, un hook no.
#
# Recibe el JSON del hook por stdin y responde por stdout. Ante cualquier duda
# deja pasar: el objetivo es atajar el descuido, no entorpecer el trabajo.

set -uo pipefail

RAMA_PROTEGIDA="main"

# `jq` no está instalado en esta máquina; python3 sí.
entrada=$(cat)
archivo=$(
  printf '%s' "$entrada" | python3 -c '
import json, sys
try:
    print(json.load(sys.stdin).get("tool_input", {}).get("file_path", ""))
except Exception:
    print("")
' 2>/dev/null
) || exit 0

# Sin archivo destino no hay nada que evaluar.
[ -n "$archivo" ] || exit 0

# Fuera de un repositorio git, el hook no opina.
repo=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -n "$repo" ] || exit 0

# Sólo protege archivos de este repositorio. Editar el archivo de planes o
# cualquier cosa fuera del árbol sigue siendo libre.
case "$archivo" in
"$repo"/*) ;;
*) exit 0 ;;
esac

# Escape del usuario. Documentado en AGENTS.md: lo crea la persona, no el agente.
[ -e "$repo/.claude/permitir-main" ] && exit 0

rama=$(git -C "$repo" branch --show-current 2>/dev/null) || exit 0
[ "$rama" = "$RAMA_PROTEGIDA" ] || exit 0

motivo="Estás en \`$RAMA_PROTEGIDA\` y no se modifica el repositorio desde ahí. \
Creá una rama para esta unidad de trabajo con el formato \`tipo/descripcion-corta\` \
(por ejemplo \`feat/usuarios-y-roles\`) y repetí la edición ahí. No intentes \
saltear este bloqueo: crear \`.claude/permitir-main\` es decisión del usuario."

python3 -c '
import json, sys
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": sys.argv[1],
    }
}))
' "$motivo"

exit 0
