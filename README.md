# Agent Skills

Repo to store user-level skills.

Also holds user-level AGENTS.md.

## Branch model

The `vipps` branch carries work-specific skills and overrides as a rebased patch series on top of `main`. Generic improvements always land on `main` first; `vipps` rebases to pick them up.

To see what `vipps` adds on top of `main`: `git log --oneline main..vipps`
