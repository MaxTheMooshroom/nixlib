{ lib, lib', ... }:
let
  trivial' = lib'.trivial;
  strings' = lib'.strings;

  inherit (lib.filesystem)
    pathIsDirectory
    pathIsRegularFile
    ;
in
{
  /**
    Check if 2 values are equal.

    # Type

    ```
    eq :: Any -> Any -> Bool
    ```

    # Examples

    Standard use is partial-parameterization, as such:

    ```
    isFoo = mlib.eq "foo";

    result = isFoo "bar"; # false
    ```
  */
  eq  = a: b: b == a;
  neq = a: b: a != b;

  swap    = x: f: f x;
  dup     = f: x: f x x;
  turn    = f: g: x: f (g x);
  fanout  = f: g: x: (f x) (g x);

  /**
    # Equivalence

    ```
    f: g: a: b: f (g a b)
    ```
  */
  turn2 = with trivial'; turn turn turn;

  /**
    call a function with a list of parameters.

    # Inputs

    `f`

    : 1\. The function to pass the arguments to. Takes any number
          of arguments (each of a type determined by `f` rather than
          by `callWith`) and a return type of any (like the parameters,
          as determined by `f` rather than `callWith`)

    `list`

    : 2\. A list of the arguments to pass to `f`.

    # Type

    ```
    callWith :: Args -> [Arg] -> a

    Args :: (Arg -> Any) | (Arg -> Args)

    Arg :: Any
    ```

    # Equivalence

    ```
    f: list: foldl' (f': x: f' x) f list
    ```
  */
  callWith = builtins.foldl' lib.id;

  negate = x: !x;

  /**
    Pass `x` to `f` and apply logical negation to the result.

    # Type

    ```
    not :: (Any -> bool) -> (Any -> bool)
    ```
  */
  not = f: x: !f x;
  notAttrs      = trivial'.not builtins.isAttrs;
  notBool       = trivial'.not builtins.isBool;
  notFloat      = trivial'.not builtins.isFloat;
  notFunction   = trivial'.not builtins.isFunction;
  notInt        = trivial'.not builtins.isInt;
  notList       = trivial'.not builtins.isList;
  notNull       = trivial'.not builtins.isNull;
  notPath       = trivial'.not builtins.isPath;
  notDerivation = trivial'.not lib.isDerivation;

  /**
    For a given value `x`, return a function that for any input returns `x`.

    # Arguments

    `x`
    : 1\. The value that should always be returned.

    # Type

    ```
    const :: a -> (Any -> a);
    ```
  */
  const     = x: _: x;
  True      = trivial'.const true;
  False     = trivial'.const false;
  Null      = trivial'.const null;
  EmptySet  = trivial'.const {};

  ifElse = cond: a: b: if cond then a else b;

  getType = value:
    if    lib.isAttrs value && lib.isStringLike value
    then  "stringCoercibleSet"
    else  builtins.typeOf value;

  /**
    Pipe a value through a list of functions, where the result of each
    function is the argument to the next function in the list.

    # Arguments

    `nul`
    : 1\. The value being piped through the functions.

    `list`
    : 2\. The list of functions to pipe the value through.

    # Type

    ```
    composeFunctions :: Any -> [(Any -> Any)] -> Any
    ```
  */
  pipe = builtins.foldl' trivial'.swap;

  min0 = lib.max 0;
  max0 = lib.min 0;
  thresholdMax = N: x: trivial'.ifElse (N <= x) 0 x;
  clamp = lib.flip (trivial'.turn trivial'.turn2 lib.max) lib.min;

  getLevenshteinFast = trivial'.turn builtins.filter strings'.levenshteinFast;

  isImportable = x:
    (lib.strings.isStringLike x)
    && (
      let p = /. + (toString x); in
      (builtins.pathExists p)
      && (
            (pathIsRegularFile p && lib.hasSuffix ".nix" p)
        ||  (pathIsDirectory p && builtins.pathExists (p + "/default.nix"))
      )
    );

  updateAttrsWith = attrs: update: attrs // (update attrs);
}
