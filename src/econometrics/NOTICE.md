# Lee–Strazicich implementation notice

`lee_strazicich_one_break.R` is a focused adaptation of the serial R implementation in the [LeeStrazicichUnitRoot](https://github.com/hannes101/LeeStrazicichUnitRoot) repository by Johannes Lips, retrieved 2026-08-30.

The upstream repository is licensed under GNU GPL v3.0. The accompanying `GPL-3.0.txt` file retains the applicable license text. The upstream implementation is attributed to Johannes Lips, with the repository crediting the original work of Junsoo Lee and Mark C. Strazicich and a RATS implementation by Tom Doan.

This project uses a focused implementation of the Lee–Strazicich one-break Model C specification, incorporating both a level and trend structural break.

## Methodological references

- Lee, J. and Strazicich, M. C. (2004). *Minimum LM Unit Root Test with One Structural Break*. Appalachian State University Working Paper 04-17.
- Lee, J. and Strazicich, M. C. (2003). *Minimum Lagrange Multiplier Unit Root Test with Two Structural Breaks*.

The present project uses the one-break specification only. The two-break reference is retained as methodological background and is not represented as an implementation of the two-break test in this repository.