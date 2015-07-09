import sys
from os import path
from glob import glob


def projects(args):
    for csprojFile in glob("*/*.csproj"):
        print(path.dirname(csprojFile))


def updateReferences(args):
    import csproj
    for csprojFile in glob("*/*.csproj"):
        projName = path.dirname(csprojFile)
        projFile = path.join(projName, "project.lock.json")
        if path.exists(projFile):
            csproj.updateReferences(projName, csprojFile, projFile)

if len(sys.argv) < 2:
    exit(1, "Usage: project.py TASK [ARGS]*")

cmd = sys.argv[1]
args = sys.argv[2:]

if not cmd in globals():
    exit(1, "Unknown task")

cmd = globals()[cmd]

if not hasattr(cmd, '__call__'):
    exit(1, "Unknown task")

cmd(args)
