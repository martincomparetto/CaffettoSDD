---
name: push
description: Pushea la rama actual a GitHub verificando la identidad de git. Nunca mergea, nunca cambia de rama, nunca commitea. Se usa cuando el usuario pide pushear, subir la rama o hacer push.
---

# Push

Pushea **la rama actual** a `origin`. Nada más.

## Qué NO hacer, nunca

- **No mergees.** Ni a `main` ni a ninguna otra rama, aunque la rama actual
  parezca terminada. El merge se pide aparte.
- **No cambies de rama ni crees ramas.** Se pushea la que está checkouteada,
  incluida `main`.
- **No commitees ni hagas stash.**
- **No fuerces el push.** Sin `--force` ni `--force-with-lease`. Si el remoto lo
  rechaza, informá el motivo y frená.

## Pasos

1. `git status --porcelain`. Si hay archivos **trackeados** modificados o en
   staging, **frená sin pushear** y mostrale al usuario qué quedó pendiente.
   Los archivos sin trackear (`??`) sólo se avisan: no frenan el push.

2. `git config user.name`. Tiene que ser `martincomparetto`. Si no coincide,
   frená y decíselo — no la cambies por tu cuenta.

3. `git branch --show-current`. Si viene vacío, el HEAD está desprendido: frená.

4. Pusheá:
   - `git push` si la rama ya tiene upstream.
   - `git push -u origin <rama>` si todavía no lo tiene.

5. Informá la rama pusheada, el rango de commits y el link al pull request si
   git lo devuelve.
