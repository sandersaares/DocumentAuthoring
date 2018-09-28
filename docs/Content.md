# Content Guide

The following inputs are combined to create a document:

* Document text.
* Images.
* Diagrams generated from PlantUML text files.

This guide describes the possibilities for content authoring available with each type of input.

# Authoring document text

The main contents of a document are in a Bikeshed file with the extension `.bs.md`.

The format of the document is a mixture of HTML and Markdown plus some custom elements defined by the Bikeshed document format for describing metadata and data type definitions.

In general, use Markdown for text authoring whenever possible. Some features (e.g. images and tables) require you to use HTML. Defining data structures will require you to use specialized Bikeshed syntax to ensure proper referencing behavior.

More detailed guidance on common scenarios follows below.

# Using HTML

HTML will technically work but you should avoid it unless you truly need it. Prefer Markdown.

# Basic Markdown formatting

Textual content of the document uses Markdown for formatting. See [Markdown Reference](https://commonmark.org/help/) for examples.

Various Bikeshed extensions are added to the Markdown language. You can read about the details in the [Bikeshed reference](https://tabatkins.github.io/bikeshed/#markup-shortcuts).

NB! Not all Markdown features are supported (e.g. you cannot embed images using Markdown and have to use HTML).

# Headings and references

To uniquely identify a heading for referencing purposes, you must explicitly add an anchor. The anchor is the `{#xyz}` tag at the end of the heading.

```markdown
## Powering machine learning with XML 1.0 ## {#powering-ml-with-xml}
```

Use the anchor to reference the heading elsewhere in the text. The link will automatically be replaced with the heading text.

```markdown
VR solutions often benefit from XML-enabled machine learning, as described in the [[#powering-ml-with-xml]] chapter.
```

**Always add an anchor to every heading**, even if you do not currently reference them - other people might want to; if not in the document then perhaps in hyperlinks on the web!

# Inserting images

Use HTML to insert images. The recommended format is:

```html
<figure>
	<img src="Images/ExampleWorkflow-Live.png" />
	<figcaption>Example of workflow for Live Content preparation.</figcaption>
</figure>
```

You must place all images in the `Images/` directory (subdirectories are allowed).

# Inserting links to websites

Use Markdown link syntax for links to the web.

```markdown
[Click here for an adventure](https://zombo.com)
```

# Tables

Use HTML for tables.

```html
<!-- class=def is a builtin style that is a bit nicer than plaintext tables. -->
<table class="def">
	<tr>
		<th>Usage</th>
		<th>Algorithm</th>
	</tr>
	<tr>
		<td>Content Key wrapping</td>
		<td>AES256-CBC, PKCS #7 padding</td>
	</tr>
	<tr>
		<td>Encrypted key MAC</td>
		<td>HMAC-SHA512</td>
	</tr>
</table>
```

# Highlighting notes

Paragraphs starting with `Note: ` will be highlighted in the output document.

```
Note: Bees can fly up to two miles to find nectar and pollen.
```

For additional information about special block formatting that applies in this and similar scenarios, see the [Bikeshed documentation](https://tabatkins.github.io/bikeshed/#notes-etc).

# References to external documents

You can directly reference any document listed in the [SpecRef catalog](https://specref.org) using `[[!rfc7168]]` (normative) and `[[rfc2324]]` (informative) bibliography tags. Such tags will cause a suitable hyperlink to be generated and, if the reference is normative, the referenced document to be added to the bibliography section.

[SpecRef accepts contributions](https://github.com/tobie/specref#updating--adding-new-references), If you do not find a document in the catalog, consider adding it to SpecRef instead of maintaining a manually updated bibliography section.

To add custom bibliography entries, define a `<pre class=biblio>` section containing SpecRef style JSON. This will be simply be appended to any SpecRef data set when building your document.

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

# Code blocks

Use `<xmp>` for code blocks. Contents of this element are interpreted as plain text, with no need for any escaping of special characters.

For syntax highlighting, specify the language with `<xmp highlight="xml">`.

To add line numbers, specify `<xmp line-numbers>`.

# Embedding diagrams

You are recommended to generate diagrams from text files, as they enable an easier editing and review experience than images. This document authoring workflow supports diagram generation from [PlantUML files](http://plantuml.com/).

All diagrams must be placed in the `Diagrams/` directory (subdirectories are OK). Diagram files have the `.wsd` extension.

At document build time, a `.png` file is generated for each diagram. Simply use this file as you would any other image (except for the fact that these are in the `Diagrams/` directory).

See the PlantUML documentation for syntax examples (it is a very flexible language). A very basic diagram example is given below.

## Example: component diagram

A `Diagrams/ComponentDiagram.wsd` file with the following content will produce the below image as `Diagrams/ComponentDiagram.png`.

```plantuml
@startuml

package "Recipient A delivery data" {
    [Document key] as DKforA #lightskyblue
    [Recipient A public key] as KpubA

    KpubA <-- DKforA : Encrypted with
}

package "Recipient B delivery data" {
    [Document key] as DKforB #lightskyblue
    [Recipient B public key] as KpubB

    KpubB <-- DKforB : Encrypted with
}

[Content key 1] as Key1 #lightskyblue
[Content key 2] as Key2 #lightskyblue

Key1 -up-> DKforA : Encrypted with
Key1 -up-> DKforB

Key2 -up-> DKforA : Encrypted with
Key2 -up-> DKforB

@enduml
```

![](Images/ComponentDiagram.png)

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

# Restrictions on Bikeshed capabilities

Due to process limitations it is not possible to include code blocks (or other content) from standalone files, even though the [Bikeshed documentation does define an "include" feature](https://tabatkins.github.io/bikeshed/#including) for this purpose. You must embed all your textual content directly in the main Bikeshed document.