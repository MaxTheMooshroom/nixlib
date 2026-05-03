{ lib, lib' }:
let
  types' = lib'.types;

  inherit (lib)
    types
    mkOption
    mkOptionType
    ;

  inherit (lib'.trivial)
    isImportable
    updateAttrsWith
    ;

  function = mkOptionType {
    name = "function";
    description = "nix function";
    descriptionClass = "noun";
    check = lib.isFunction;
  };

  importable = types.anything // {
    check = isImportable;
  };

  importedAs = types.coercedTo importable builtins.import;
  fixedPointOf = types.coercedTo types'.function lib.fix;

  package-function = importedAs
    (updateAttrsWith
      (types.functionTo types.package)
      (old: {
        name = "package-function";
        check = x: old.check x && (lib.functionArgs x) != {};
      })
    );

  packageSet-function = types.uniq
    (types'.importedAs
      (types.functionTo
        (updateAttrsWith (types.functionTo types'.packageSet) (old: {
          name = "packageset-function";
          description = "fixed-point operator over a package-function and its packageset";
          descriptionClass = "noun";

          # Is `f` a valid fixed-point function over a package-function?
          # We can't check the resulting package-set for validity until
          # after `f` has been passed to `callPackageSetWith` or a
          # recursively nested `callPackageSet`. To validate that, we should
          # use the merge function to wrap the function such that before the
          # result is returned, we validate that it has the expected
          # properties of a package-set.
          check = f:
                lib.isFunction f
            &&  lib.functionArgs f == {}
            &&  (
              let fp = lib.fix f; in
                  lib.isFunction fp
              &&  lib.functionArgs fp != {}
            );

          merge =
            let
              hasFunction = s: x: lib.isFunction (s.${x} or null);
            in
              loc: defs:
                let
                  def = (builtins.head defs).value;
                  hasFunction' = hasFunction def;
                in
                  lib.flip lib'.asserts.packageSets.wrapWithAsserts def [
                    (x: (x._type or null) == "pkg-set")
                    (hasFunction' "callPackage")
                    (hasFunction' "callPackageSet")
                    (hasFunction' "overridePackage")
                    (hasFunction' "overrideSet")
                    (hasFunction' "packageSet")
                  ];
        }))
      )
    );

  packageSet-member = types.oneOf [
    types.package
    types'.packageSet
  ];

  packageSet = types.submodule {
    freeformType = packageSet-member;

    options = {
      _type = mkOption {
        type = types.str;
      };

      callPackage = mkOption {
        type = types'.function;
      };

      callPackageSet = mkOption {
        type = types'.function;
      };

      overridePackage = mkOption {
        type = types'.function;
      };

      overrideSet = mkOption {
        type = types'.function;
      };

      packageSet = mkOption {
        type = types'.packageSet-function;
      };
    };

    config = {
      _type = lib.mkForce "pkg-set";
    };
  };

  strLike = mkOptionType {
    name = "string-like";
    description = "string-like value";
    descriptionClass = "noun";
    check = lib.isStringLike;
    merge = lib.options.mergeEqualOption;
  };

  coercedStr =
    types.coercedTo
      types'.strLike
      builtins.toString
      types.str;
in
{
  inherit
    coercedStr
    fixedPointOf
    function
    importable
    importedAs
    package-function
    packageSet
    packageSet-function
    packageSet-member
    strLike
    ;
}
