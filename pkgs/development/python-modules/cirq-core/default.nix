{ lib
, stdenv
, buildPythonPackage
, pythonOlder
, pythonRelaxDepsHook
, fetchFromGitHub
, fetchpatch
, duet
, matplotlib
, networkx
, numpy
, pandas
, requests
, scipy
, sortedcontainers
, sympy
, tqdm
, typing-extensions
  # Contrib requirements
, withContribRequires ? false
, autoray ? null
, opt-einsum
, ply
, pylatex ? null
, pyquil ? null
, quimb ? null
  # test inputs
, pytestCheckHook
, freezegun
, pytest-asyncio
}:

buildPythonPackage rec {
  pname = "cirq-core";
  version = "1.1.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "quantumlib";
    repo = "cirq";
    rev = "refs/tags/v${version}";
    hash = "sha256-5j4hbG95KRfRQTyyZgoNp/eHIcy0FphyEhbYnzyUMO4=";
  };

  sourceRoot = "source/${pname}";

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  
  pythonRelaxDeps = [ "matplotlib" "networkx" "numpy" ];
  
  propagatedBuildInputs = [
    duet
    matplotlib
    networkx
    numpy
    pandas
    requests
    scipy
    sortedcontainers
    sympy
    tqdm
    typing-extensions
  ] ++ lib.optionals withContribRequires [
    autoray
    opt-einsum
    ply
    pylatex
    pyquil
    quimb
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    freezegun
  ];

  disabledTestPaths = lib.optionals (!withContribRequires) [
    # Requires external (unpackaged) libraries, so untested
    "cirq/contrib/"
    # No need to test the version number
    "cirq/_version_test.py"
  ];

  # Numpy 1.24 breaks this package
  doCheck = false;

  disabledTests = [
    # Tries to import flynt, which isn't in Nixpkgs
    "test_metadata_search_path"
    # Fails due pandas MultiIndex. Maybe issue with pandas version in nix?
    "test_benchmark_2q_xeb_fidelities"
  ];

  meta = with lib; {
    description = "Framework for creating, editing, and invoking Noisy Intermediate Scale Quantum (NISQ) circuits";
    homepage = "https://github.com/quantumlib/cirq";
    changelog = "https://github.com/quantumlib/Cirq/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger fab ];
    broken = (stdenv.isLinux && stdenv.isAarch64);
  };
}
