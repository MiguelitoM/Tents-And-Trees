# 🌳 Tents and Trees

## 🔍 Overview
This project is a Prolog-based solver for the classic logic puzzle **“Tents and Trees”**, implemented for the Logic Programming course (2023–2024). The game involves placing tents next to trees on a grid while respecting a set of constraints:

- Each **tree** must be matched to exactly one **adjacent tent** (up, down, left, or right).
- **Tents** cannot be adjacent to each other, not even diagonally.
- The number of tents per **row and column** is predefined.

This implementation allows solving specific puzzles by applying strategies and logic reasoning, along with fallback to **trial and error** when necessary.

## 🧪 Testing
To run and test this project, you need to have [SWI-Prolog](https://www.swi-prolog.org/Download.html) installed on your system.

### Load the project in SWI-Prolog
```bash
swipl Project.pl
```

Then, execute the test queries in the Prolog console:

```prolog
puzzle(6-13, P), resolve(P), sol(6-13, S), P == S.
puzzle(6-14, P), resolve(P), sol(6-14, S), P == S.
puzzle(8-1, P), resolve(P), sol(8-1, S), P == S.
```
