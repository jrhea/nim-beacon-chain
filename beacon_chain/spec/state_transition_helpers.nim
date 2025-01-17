# beacon_chain
# Copyright (c) 2018-2019 Status Research & Development GmbH
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  # Standard library
  sets,
  # Internals
  ./datatypes, ./digest, ./beaconstate

# Logging utilities
# --------------------------------------------------------

# TODO: gather all logging utilities
#       from crypto, digest, etc in a single file
func shortLog*(x: Checkpoint): string =
  "(epoch: " & $x.epoch & ", root: \"" & shortLog(x.root) & "\")"

# Helpers used in epoch transition and trace-level block transition
# --------------------------------------------------------

# https://github.com/ethereum/eth2.0-specs/blob/v0.8.3/specs/core/0_beacon-chain.md#helper-functions-1
func get_attesting_indices*(
    state: BeaconState, attestations: openarray[PendingAttestation],
    stateCache: var StateCache): HashSet[ValidatorIndex] =
  result = initSet[ValidatorIndex]()
  for a in attestations:
    result = result.union(get_attesting_indices(
      state, a.data, a.aggregation_bits, stateCache))

func get_unslashed_attesting_indices*(
    state: BeaconState, attestations: openarray[PendingAttestation],
    stateCache: var StateCache): HashSet[ValidatorIndex] =
  result = get_attesting_indices(state, attestations, stateCache)
  for index in result:
    if state.validators[index].slashed:
      result.excl index
