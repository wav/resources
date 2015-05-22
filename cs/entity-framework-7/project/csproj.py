from prelude import *
from lxml import etree
from os import path, rename


def updateReferences(projName, csprojFile, projFile):
    print("Updating project references for " + projName)
    csproj = CSProj(csprojFile)
    rename(csprojFile, csprojFile + ".bk")
    proj = ProjectJSON(projFile)
    File.write(
        csprojFile,
        csproj.withReferences(proj.compileAssemblies()))


class CSProj(object):

    XMLNS = "http://schemas.microsoft.com/developer/msbuild/2003"

    class ItemGroup(XmlElement):

        def __init__(self, members):
            if not members or len(members) == 0:
                raise ValueError("members must be non empty")
            children = [None] + list(intersperse(members, None)) + [None]
            XmlElement.__init__(self, "ItemGroup", None, children)

    class Reference(XmlElement):
        def __init__(self, include, hintPath):
            if not include or not hintPath:
                raise ValueError("include and hintPath must be set")
            hintPath = hintPath.replace("/", "\\")
            XmlElement.__init__(
                self,
                "Reference", {"Include": include},
                [None, XmlElement("HintPath", None, [hintPath]), None])

    def __init__(self, proj):
        if isinstance(proj, str):
            self.proj = File.readXML(proj)
        else:
            self.proj = proj

    findReferences = etree.XPath('//ms:Project/ms:ItemGroup/ms:Reference',
                                 namespaces={'ms': XMLNS})

    def withReferences(self, references):
        refs = list([CSProj.Reference(i, h) for (i, h) in references.items()])
        proj = None
        oldRefs = CSProj.findReferences(self.proj)
        if len(oldRefs) > 0:
            group = oldRefs[0].getparent()
            proj = group.getparent()
            proj.remove(group)
        if proj is None:
            proj = self.proj.xpath(
                '//ms:Project',
                namespaces={'ms': XMLNS})
        proj.append(CSProj.ItemGroup(refs).XML())
        return CSProj(proj.getroottree())

    def __str__(self):
        return etree.tostring(
            self.proj,
            pretty_print=True).replace("><", ">\n<")
            # '\n' is a hack, empty nodes aren't entered!


class ProjectJSON(object):

    FWK = "DNX,Version=v4.5.1"

    def __init__(self, path):
        self.proj = File.readJSON(path)

    def compileAssemblies(self):
        assemblies = []
        for (n, lib) in self.proj["libraries"].items():
            if ProjectJSON.FWK in lib["frameworks"]:
                fwk = lib["frameworks"][ProjectJSON.FWK]
                if "compileAssemblies" in fwk:
                    paths = [ (p, path.basename(p), path.splitext(p)[1]) for p in fwk["compileAssemblies"] ]
                    assemblies += [ (str(p[1]), str(path.join("packages",n,p[0]))) for p in paths if p[2].lower() == ".dll" ]
        return dict(assemblies)
