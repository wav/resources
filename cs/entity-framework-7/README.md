## Brief

This is a sample C# project that builds on Mac OS.

The python module `project` in this solution has tasks that will set the project references in a `*.csproj` based on an adjacent `project.lock.json` file.

> This is only necessary until there is wider support by IDE's for the `*.xproj` format which doesn't contain references and assumes they come from the `project.json` file. [reference](https://visualstudio.uservoice.com/forums/121579-visual-studio/suggestions/7225193-kproj-xproj-should-not-be-associated-with-asp-net)

Add additional tasks to `project/__main__.py`

## Getting started

Review `> project.sh` then run

```bash
> ./project.sh prepare
```
