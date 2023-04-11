{ lib
, pkgs
, buildPythonPackage
, pythonOlder
, pythonRelaxDepsHook
, pytestCheckHook
, pytest-xdist
, fetchFromGitHub
, substituteAll
, cmake
, pybind11
, gtest
, stim
, scipy
, numpy
, networkx
, rustworkx
, matplotlib
}:

buildPythonPackage rec {
  pname = "pymatching";
  version = "2.1.0";
  format = "setuptools";

  disabled = pythonOlder "3.6";

  src = pkgs.fetchFromGitHub {
    owner = "oscarhiggott";
    repo = "PyMatching";
    rev = "refs/tags/v${version}";
    hash = "sha256-fhYSWp6e8bkgxOm449Ms66yEuqMm7jfpdGEgAytwVgA=";
  };

  nativeBuildInputs = [
    cmake
    pythonRelaxDepsHook
    gtest
  ];

  dontUseCmakeConfigure = true;

  pythonRemoveDeps = [ "retworkx" ];

  propagatedBuildInputs = [
    scipy
    numpy
    networkx
    rustworkx
    matplotlib
    stim

    numpy
    pybind11
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
    gtest
    pybind11
  ];

  patches = [
    (substituteAll {
     src = ./0001-rename-retworkx-to-rustworkx.patch;
    })
    (substituteAll {
      src = ./dependencies.patch;
      gtest_src = gtest.src;
      stim_src = stim.src;
    })
  ];

  postUnpack = ''
    rm -rf $sourceRoot/pybind11
    ln -s ${pybind11.src} $sourceRoot/pybind11
  '';
  
  meta = {
    description = "A package for decoding quantum error correcting codes using minimum-weight perfect matching.";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ chrispattison ];
    homepage = "https://github.com/oscarhiggott/PyMatching";
  };

  pythonImportsCheck = [ "pymatching" ];

  enableParallelBuilding = true;

  disabledTestPaths = [
    "pybind11"
    "tests/cli_test.py"
  ];
}
