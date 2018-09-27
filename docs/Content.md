# Content Guide

The following inputs are combined to create a document:

* Document text.
* Images.
* Diagrams generated from PlantUML text files.
* External assets to be embedded at build time (e.g. code examples or XML Schema files).

This guide describes the possibilities for content authoring available with each type of input.

# Authoring document text

The main contents of a document are in a Bikeshed file with the extension `.bs.md`.

The format of the document is a mixture of HTML and Markdown plus some custom elements defined by the Bikeshed document format for describing metadata and data type definitions.

In general, use Markdown for text authoring whenever possible. Some features (e.g. images and tables) require you to use HTML. Defining data structures will require you to use specialized Bikeshed syntax to ensure proper referencing behavior.

More detailed guidance on common scenarios follows below.

# Basic Markdown formatting

Textual content of the document uses Markdown for formatting. See [Markdown Reference](https://commonmark.org/help/) for examples.

NB! Not all Markdown features are supported (e.g. you cannot embed images using Markdown and have to use HTML).

# Headings and references

To uniquely identify a heading for referencing purposes, you must explicitly add an anchor. The anchor is the `{#xyz}` tag at the end of the heading.

```markdown
## Powering machine learning with XML 1.0 ## {#powering-ml-with-xml}
```

This allows you to change the text of the heading without breaking references.

```markdown
VR solutions often benefit from XML-enabled machine learning, as described in the [[#powering-ml-with-xml]] chapter.
```

**Always add an anchor to every heading**, even if you do not currently reference them - other people might want to, e.g. in hyperlinks on the web!

# Inserting images

Use HTML to insert images. The recommended format is:

```html
<figure>
	<img src="Images/ExampleWorkflow-Live.png" />
	<figcaption>Example of workflow for Live Content preparation.</figcaption>
</figure>
```

Place all images in the `Images/` directory.

# Inserting links to websites

Use Markdown link syntax for links that reference resources on the web.

```markdown
[Click here to win a prize](https://example.com)
```

# Using HTML

HTML will technically work but you should avoid it unless you truly need it. Prefer Markdown when possible.

# Embedding diagrams

TODO

# Embedding assets

TODO