from lxml import etree
import json


class File(object):

    @staticmethod
    def write(path, data):
        with open(path, "w") as f:
            return f.write(str(data))

    @staticmethod
    def read(path):
        with open(path) as f:
            return "".join(f.readlines())

    @staticmethod
    def readXML(path):
        return etree.XML(File.read(path))

    @staticmethod
    def readJSON(path):
        return json.loads(File.read(path))


class XmlElement(object):

    @staticmethod
    def Text(s):
        r = "\n"
        if s is not None:
            r = s
        return r

    def __init__(self, tag, attributes=None, children=[]):
        if not type(tag) == str:
            raise ValueError("tag: %s" % str(self._tag))
        if attributes and type(attributes) != dict:
            raise ValueError("attrbutes: %s" % str(self._attributes))
        for child in children:
            if child and not (
                    isinstance(child, XmlElement) or
                    type(child) == str):
                raise ValueError("*children: %s" % str(type(child)))
        self._tag = tag
        self._attributes = attributes
        self._children = children

    def XML(self):
        e = None
        if self._attributes:
            e = etree.Element(self._tag, **self._attributes)
        else:
            e = etree.Element(self._tag)
        cs = self._children
        last = None
        if len(cs) > 0:
            if type(cs[0]) == str:
                # this doesn't enter empty nodes!
                e.text = XmlElement.Text(cs[0])
                cs = cs[1:]
            for c in cs:
                if isinstance(c, XmlElement):
                    last = e.append(c.XML())
                elif last is not None:
                    # this doesn't enter empty nodes!
                    last.tail = XmlElement.Text(c)
        return e

    def __str__(self):
        return etree.tostring(self.XML(), pretty_print=True)


def intersperse(iterable, delimiter):
    it = iter(iterable)
    yield next(it)
    for x in it:
        yield delimiter
        yield x
