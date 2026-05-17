{ lib, lib', ... }:
let
  lists' = lib'.lists;
  trivial' = lib'.trivial;

  inherit (builtins)
    add
    elemAt
    foldl'
    genList
    head
    length
    tail
    ;

  inherit (lib.lists)
    imap0
    imap1
    ;

  inherit (lib'.trivial)
    const
    turn
    ;
in
{
  splitFor = f: l: f (head l) (tail l);

  /**
    Create a list consisting of `n` copies of `elem`.

    # Arguments

    `elem`
    : 1\. The item to replicate.

    `n`
    : 2\. The number of times to replicate `elem`.

    # Type

    ```
    replicate' :: a -> Integer -> [a]
    ```
  */
  replicate' = turn genList const;

  sum = foldl' lib.add 0;

  enumerated0 = imap0 (idx: value: { inherit idx value; });
  enumerated1 = imap1 (idx: value: { inherit idx value; });

  ifoldl'0 = f: acc: list:
    foldl'
      (acc: { idx, value }: f idx acc value)
      acc
      (lists'.enumerated0 list);

  ifoldl'1 = f: acc: list:
    foldl'
      (acc: { idx, value }: f idx acc value)
      acc
      (lists'.enumerated1 list);

  sublist = start: count: list:
    let
      threshold-max = N: x: lib'.trivial.ifElse (N < x) 0 x;

      count' = threshold-max (length list) (start + count);
      start' = lib'.trivial.min0 start;
    in
      builtins.genList
        (lib'.turn (elemAt list) (add start'))
        count';

  /**
    # Equivalence

    ```
    
    ```
  */
  take = count:
    trivial'.fanout
      (lib'.turn genList elemAt)
      (lib'.turn (lib.max count) length);
}
