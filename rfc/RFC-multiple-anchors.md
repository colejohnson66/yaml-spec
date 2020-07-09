RFC-000
=======

Allow multiple anchors on a node


| Key | Value |
| --- | --- |
| Target | 1.3 |
| Status | 0 |
| Requires | |
| Related | |
| Discuss | [Issue 0](../../issues/0) |
| Tags | [anchor]() |


## Problem

The spec allows for a single anchor to be placed on a node.

```
--- &a
b
```

While this is fine for regular use, when a compositional YAML DOM is created multiple anchors may end up being set on a single node.

## Proposal

We propose to relax this requirement so that multiple anchors may be placed on a node.

```
--- &a &b
b
```

In this case anchors are preserved across merges so no loss of information is observed.


## Explanation

Multiple anchors allow preservation of anchors across multiple merge operations.

For example assume a method to *merge* the following two documents preserving the anchors and their references.

```
# X
---
a: &aa
  b: c
d: *aa
```

```
# Y
---
a: &ii
  e: f
g: *ii
```

```
# X + Y (loss of information)
---
a: &aa
  b: c
  e: f
d: *aa
g: *aa
```

With single anchor semantics the merge is impossible while preserving both anchors.
At best only a single anchor maybe be preserved.
Any subsequent merges with a reference to the erased anchor are going to fail.

Introducing multiple anchors the previous merge becomes

```
# X + Y (no loss of information)
---
a: &aa &ii
  b: c
  e: f
d: *aa
g: *ii
```

An additional merge with the following document

```
# Z
h: *ii
```

Produces the expected result

```
# X + Y + Z (no loss of information)
---
a: &aa &ii
  b: c
  e: f
d: *aa
g: *ii
h: *ii
```