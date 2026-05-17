{ lib, lib', ... }:
{
  levenshteinFast = lib.levenshteinAtMost 2;
}
