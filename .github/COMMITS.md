# Commits

How work is committed in this repository, by hand or by an agent working through REVIEW.md.

## When

Each logical batch of work is committed on its own once it is finished and its documentation says
what it does. In this repository the owner commits and pushes from their own tools; a working
session changes the files and commits nothing, reporting each batch by file in REVIEW.md's Replies
and to the reviewing session, so the owner commits the work in batches of that size.

A branch exists only while a second session writes to the repository, and it is named for its
work, such as `modeling`, never under `claude/` nor with a random string. Its
commits are cherry-picked onto `main` as they are, with the author reset to the repository's and
no trailer added, and the branch is deleted once they are on `main`. Every commit's author and
committer are the owner's identity, which a session sets as `user.name` and `user.email` before its
first commit.

A batch is one thing somebody would want to read, revert or cherry-pick alone, such as a fix, a
feature with its tests and its docs, or a refactor. Work that is still half done stays uncommitted
until it is whole. REVIEW.md is edited in the tree by the reviewing session and goes in with whichever batch the
owner commits next.

## Before committing

Before a commit is made, [STYLE.md](STYLE.md) is read and applied to everything the commit adds, its
comments, XML documentation, messages, Markdown, shader comments and script comments, and to the
commit message itself. The checks at the end of STYLE.md are run over what is staged rather than the
whole tree, so a hit is in the work being committed and is fixed before it goes in:

```bash
# No personal name, in any form, in what is staged; the pattern lives in the shell's FORBIDDEN_NAMES
# variable and never in the repository.
git diff --cached | grep '^+' | grep -niE "$FORBIDDEN_NAMES"
# The added lines alone, read rather than counted, since arithmetic matches the spaced hyphen.
git diff --cached | grep '^+' | grep -niE '[—–]| - |\b(is|are|was|were) what\b|which is what|\bwants?\b|\bjust\b|\bsimply\b|!$|light that bounces|give[sn]? off|glowing|\bdriv(e|en|es|ing)\b|in the manner of|ground floor|out of the box|under the hood|at a glance|a handful of|a great deal of|in the wild|plumbing|a long way'
```

The grep finds the mechanical faults. The rest of STYLE.md (colons inside a sentence, the register,
tone, prose about earlier revisions, American spelling) is checked by reading the staged diff, since
no pattern tells a label from a joint. A fix found here is made and staged, and the commit follows.

## The message

Three lines, of which the first reads as nothing and the third says what the commit does.

1. **Three invisible marks**, U+200E (the left-to-right mark) three times with a space between each
   (`‎ ‎ ‎`), so the subject line looks empty in a log.
2. **A blank line**, which tells Git the subject has ended and a description begins.
3. **One plain sentence** saying what the commit does and what it changed, as somebody would say it
   out loud.

The sentence has no colons, no headings, no lists, no prefixes such as `feat` or `fix`, and no
trailers. It names no tool, model or assistant, and carries no `Co-Authored-By` line. It is short,
and it follows [STYLE.md](STYLE.md) like the rest of the prose here. The history is public, so the
sentence says what a user of the repository or a contributor would notice, names no one who decided or
asked for the change, and gives the reason in their place. A message such as "Each
test writes into a folder of its own, the owner having asked for runs that never meet" says instead
that each test writes into a folder of its own so two runs never meet.

Written from a shell, so the marks are exact rather than pasted:

```bash
printf '\xe2\x80\x8e \xe2\x80\x8e \xe2\x80\x8e\n\nThe library loads in a test of its own on Linux, Windows and macOS.\n' > /tmp/msg
git commit -F /tmp/msg
```

A message that reads right in `git log --format='%B' | cat -v` shows `M-bM-^@M-^N` three times on
the first line, an empty second line and the sentence on the third.

## A batch that shares a file with another

When two batches touch one file, only the first batch's hunks are staged, so each commit holds one
thing. `git add -p` asks questions interactively and cannot be answered by an agent, so hunks are
picked from the diff and applied to the index instead:

```bash
# Stage hunks 1 and 3 of a file, numbered in the order git diff -U1 lists them.
git diff -U1 -- path/to/script.sh > /tmp/all.patch
# Keep the file header and the chosen @@ hunks, drop the rest, then:
git apply --cached --unidiff-zero /tmp/chosen.patch
```

Hunks are listed with `git diff -U1 -- path | grep -n '^@@'`. Order the commits so that a hunk
which mentions two batches goes in the later of them, after the code it describes exists.

`git diff --cached --stat` before each commit confirms what is in it, and `git status --short`
after the last one confirms nothing was left behind.
