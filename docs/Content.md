[Back to table of contents](README.md)

[Join DASH-IF on Slack!](https://join.slack.com/t/dashif/shared_invite/zt-egme869x-JH~UPUuLoKJB26fw7wj3Gg)

# How to write documents

The following inputs are combined to create a document:

* Document text.
* Images.
* Diagrams generated from PlantUML text files.
* Diagrams manually exported from yEd files.

This guide describes the possibilities for content authoring available with each type of input.

For a full document example, take a look at the [DocumentAuthoringExample](https://github.com/Dash-Industry-Forum/DocumentAuthoringExample) repository, which uses the source code in [MyDocument.bs.md](https://raw.githubusercontent.com/Dash-Industry-Forum/DocumentAuthoringExample/master/MyDocument.bs.md) to arrive at the following output: [Example Document](https://dashif-documents.azurewebsites.net/DocumentAuthoringExample/master/MyDocument.html).

# Authoring document text

The main contents of a document are in a Bikeshed file with the extension `.bs.md`. The format of the document is a mixture of HTML, Markdown and Bikeshed.

In general, use Markdown for text authoring whenever possible. Some features (e.g. images and tables) require you to use HTML. Experiment to find out what works best!

# Basic formatting

[Markdown Reference](https://commonmark.org/help/) provides examples on basic formatting.

NB! Not all Markdown features are supported (e.g. you cannot embed images with Markdown). Use HTML when you have to.

# Headings and references

To uniquely identify a heading for referencing purposes, you must explicitly add an anchor. The anchor is the `{#xyz}` tag at the end of the heading.

```text
# Powering machine learning with XML 1.0 # {#powering-ml-with-xml}
```

Use the anchor to reference the heading elsewhere in the text. The link will automatically be replaced with the heading text.

```text
VR solutions often benefit from XML-enabled machine learning,
as described in [[#powering-ml-with-xml]].
```

**Always add an anchor to every heading**, even those you do not currently reference - other people might want to link to them later!

You can specify custom text for a reference using the pipe character. By default, it is simply the heading text.

```text
Machine learning solutions can gain extra venture capital
funding by [[#powering-ml-with-xml|incorporating virtual reality technologies]].
```

# Inserting images

Use HTML to insert images. The recommended format is:

```html
<figure>
	<img src="Images/ExampleWorkflow-Live.png" />
	<figcaption>Example for Live Content preparation.</figcaption>
</figure>
```

You must place all static images and manually exported diagrams in the `Images/` directory (subdirectories are allowed).

# Inserting links to websites

Use Markdown link syntax for links to the web.

```markdown
[Click here for an adventure](https://zombo.com)
```

# Tables

Use HTML for tables.

Enclose tables in `figure` tags and provide a caption using `figcaption` to enable automatic numbering.

```html
<figure>
	<table class="data">
		<thead>
			<tr>
				<th>Animal
				<th>Feet
				<th>Average height
		<tbody>
			<tr>
				<td>Duck
				<td>2
				<td>1 foot
			<tr>
				<td>Cow
				<td>4
				<td>1.612 meters
			<tr>
				<td>Cat
				<td>4
				<td>Not too much
	</table>
	<figcaption>Listing of critical animal measurements.</figcaption>
</figure>
```

The `data` class is a builtin table style suitable for presenting data. An alternative builtin style you can use is the `def` class.

# Referencing illustrations and tables

Add an ID to the `figure` element and reference it in a hyperlink.

Example of reference target:

```html
<figure id="animal-facts">
  ...
</figure>
```

Example hyperlink from same document:

```html
Memorize the <a href="#animal-facts">basic facts on important animals</a> before continuing.
```

Example hyperlink from an external document:

```html
Memorize the <a href="https://exampler.com/mydocument.html#animal-facts">basic facts on important animals</a> before continuing.
```

# Defining terms

Use the `<dfn>` element to define a term. You can use it anywhere in text but a common approach is to use a key-value table:

```text
: <dfn>apricot</dfn>
:: An apricot is a fruit, or the tree that bears the fruit, of several species in the genus Prunus
: <dfn>apple</dfn>
:: An apple is a sweet, edible fruit produced by an apple tree.
```

You can reference defined terms as follows:

```text
An [=apple=] a day keeps the doctor away! But remember that [=apricots=] are not the same as [=apples=].
```

Singular/plural matching is built-in but you can use a pipe character to specify custom text for the generated link if you need to.

```text
Not every [=apple|fruit of the apple tree=] is red.
```

# Highlighting notes

Paragraphs starting with `Note: ` and `Advisement: ` will be highlighted in the output document. Notes are considered informative, whereas advisements are normative.

```
Note: Bees can fly up to two miles to find nectar and pollen.

Advisement: Bee stings hurt!
```

# References to external documents

You can directly reference any document listed in the [SpecRef catalog](https://specref.org) using `[[!rfc7168]]` (normative) and `[[rfc2324]]` (informative) tags in text. Such tags will be replaced with a suitable hyperlink during document compilation and, if the reference is normative, the referenced document will be added to the bibliography section.

To add custom bibliography entries, define a `<pre class=biblio>` section containing a SpecRef catalog JSON snippet. This will be appended to any SpecRef data set when building your document.

Example of the bibliography data format:

```json
{
  "rfc2324": {
    "href": "https://tools.ietf.org/html/rfc2324",
    "title": "Hyper Text Coffee Pot Control Protocol (HTCPCP/1.0)",
    "authors": [
      "L. Masinter"
    ],
    "status": "Informational",
    "publisher": "IETF",
    "id": "rfc2324",
    "date": "1 April 1998"
  },
  "rfc7168": {
    "href": "https://tools.ietf.org/html/rfc7168",
    "title": "The Hyper Text Coffee Pot Control Protocol for Tea Efflux Appliances (HTCPCP-TEA)",
    "authors": [
      "I. Nazar"
    ],
    "status": "Informational",
    "publisher": "IETF",
    "id": "rfc7168",
    "date": "1 April 2014"
  }
}
```

[SpecRef accepts contributions](https://github.com/tobie/specref#updating--adding-new-references). If you do not find a document in the catalog, consider adding it to SpecRef instead of maintaining a custom bibliography section.

Note: allow up to 24 hours for caches to update after a contribution is merged to the SpecRef database.

# Code blocks

Use `<xmp>` for code blocks. Contents of this element are interpreted as plain text, with no need for any escaping of special characters.

For syntax highlighting, specify the language with `<xmp highlight="xml">`.

# Embedding diagrams - PlantUML

This document authoring workflow supports diagram generation from [PlantUML files](http://plantuml.com/).

Diagram files have the `.wsd` extension. All diagrams must be placed in the `Diagrams/` directory (subdirectories are allowed).

At document build time, a `.png` file is generated for each diagram. Simply use this file as you would any other image (except for the fact that these are in the `Diagrams/` directory).

See the [PlantUML documentation](http://plantuml.com/) for syntax examples - it is a very flexible language and supports many diagramming features. A very basic example is given below.

## Example: sequence diagram

A `Diagrams/SequenceDiagram.wsd` file with the following content will produce the below image as `Diagrams/SequenceDiagram.png`.

```plantuml
@startuml
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response

Alice -> Bob: Another authentication Request
Alice <-- Bob: Another authentication Response
@enduml
```

![](Images/SequenceDiagram.png)

# Embedding diagrams - yEd/Visio/other

If you use static diagrams, exported from yEd or Visio, simply put the yEd or Visio files in the Images directory alongside the exported images.

NB! Do not use the Diagrams directory for static diagrams - it is only for PlantUML diagrams.

For yEd image export, use the following settings:

* Format: PNG
* Clipping->Margin: 5
* Image->Transparent Background: True

# Embedding formulas

You can use TeX syntax for formulas. Surround inline content with `\(` and `\)` and block content with `$$`.

```text
When \(a \ne 0\) there are two solutions to \(ax^2 + bx + c = 0\)
and they are $$x = {-b \pm \sqrt{b^2-4ac} \over 2a}.$$
```

The above produces the following output:

![](Images/Math.png)

# Including external files

You can use `#include "filename.inc.md"` to include text from other files into the main document. This statement must be the only thing on the line and is exactly equivalent to copy-pasting the referenced file into the current file.

The file extension must be `.inc.md` and there can be no special characters in the path. Subdirectories are allowed.

# Defining data structures

If you define, for example, an XML schema or another type of data format, use the Bikeshed HTML element reference syntax to enable automatic cross-referencing.

For example, consider the following XML element:

```xml
<employee id="123">
  <name>John Jackson</name>
<employee>
```

Use `<dfn element>employee</dfn>` to mark it as an element that may have children as attributes. The common situation is to do this in a document section heading:

```text
## <dfn element>employee</dfn> element ## {#schema-employee}
```

Then use the definition list syntax below to define its children:

```text
<dl dfn-type="element-attr" dfn-for="employee">

: <dfn>id</dfn> (required, attribute, xs:integer)
:: Employee ID.

: <dfn>name</dfn> (required, xs:string)
:: The full name of the employee.

</dl>
```

You can later reference the element as `<{employee}>` and its children as `<{employee/name}>`.