# The canonical install block

One install story, one wording. `README.md` and every page under `docs/` must say **this** and nothing else. Change it here first, then propagate.

## Install via skills.sh

```bash
npx skills@latest add mattpocock/skills
```

Pick the skills you want, and which coding agents to install them on. **The installer lets you choose which skills to take: make sure `setup-skills` is one of them.**

## Single skill

```bash
npx skills@latest add mattpocock/skills --skill=<name>
```

```bash
npx skills@latest update <name>
```

`skills@latest` is the pinned spelling in all three.
