import 'package:videosdk/videosdk.dart';

enum device_type { mobile, tablet, desktop }

class ManageGrid {
  static Map<String, int>? getGridRowsAndColumns({
    required int participantsCount,
    required device_type device,
    bool isPresenting = false,
  }) {
    if (isPresenting) {
      if(participantsCount == 1)
      {
        return {'r': 1, 'c': 1, 'r0': 1};
      }

      return {'r': 1, 'c': 2, 'r0': 2};
    }

    final mobilePortrait = {
      1: {'r': 1, 'c': 1, 'r0': 1},
      2: {'r': 1, 'c': 2, 'r0': 2},
      3: {'r': 2, 'c': 2, 'r0': 2, 'r1': 1},
      4: {'r': 2, 'c': 2, 'r0': 2, 'r1': 2},
      5: {'r': 3, 'c': 3, 'r0': 2, 'r1': 2, 'r2': 1},
      6: {'r': 3, 'c': 2, 'r0': 2, 'r1': 2, 'r2': 2},
    };

    var tabPortrait = {
      ...mobilePortrait,
      7: {'r': 3, 'c': 3, 'r0': 2, 'r1': 3, 'r2': 2},
      8: {'r': 3, 'c': 3, 'r0': 3, 'r1': 2, 'r2': 3},
      9: {'r': 3, 'c': 3, 'r0': 3, 'r1': 3, 'r2': 3},
      10: {'r': 3, 'c': 4, 'r0': 3, 'r1': 4, 'r2': 3},
      11: {'r': 3, 'c': 4, 'r0': 4, 'r1': 3, 'r2': 4},
      12: {'r': 3, 'c': 4, 'r0': 4, 'r1': 4, 'r2': 4},
    };

    const smallDesktop = {
      1: {'r': 1, 'c': 1, 'r0': 1},
      2: {'r': 1, 'c': 2, 'r0': 2},
      3: {'r': 2, 'c': 2, 'r0': 2, 'r1': 1},
      4: {'r': 2, 'c': 2, 'r0': 2, 'r1': 2},
      5: {'r': 2, 'c': 3, 'r0': 3, 'r1': 2},
      6: {'r': 2, 'c': 3, 'r0': 3, 'r1': 3},
      7: {'r': 3, 'c': 3, 'r0': 2, 'r1': 3, 'r2': 2},
      8: {'r': 3, 'c': 3, 'r0': 3, 'r1': 2, 'r2': 3},
      9: {'r': 3, 'c': 3, 'r0': 3, 'r1': 3, 'r2': 3},
      10: {'r': 3, 'c': 4, 'r0': 3, 'r1': 4, 'r2': 3},
      11: {'r': 3, 'c': 4, 'r0': 4, 'r1': 3, 'r2': 4},
      12: {'r': 3, 'c': 4, 'r0': 4, 'r1': 4, 'r2': 4},
      13: {'r': 4, 'c': 4, 'r0': 3, 'r1': 3, 'r2': 3, 'r3': 4},
      14: {'r': 4, 'c': 4, 'r0': 4, 'r1': 3, 'r2': 3, 'r3': 4},
      15: {'r': 4, 'c': 4, 'r0': 4, 'r1': 4, 'r2': 3, 'r3': 4},
      16: {'r': 4, 'c': 4, 'r0': 4, 'r1': 4, 'r2': 4, 'r3': 4},
    };

    Map<int, Map<String, int>> grid = {};
    int maxCount = 6;

    if (device == device_type.mobile) {
      grid = mobilePortrait;
    } else if (device == device_type.tablet) {
      grid = tabPortrait;
    } else if (device == device_type.desktop) {
      grid = smallDesktop;
    }

    var myGrid =
        grid[participantsCount > maxCount ? maxCount : participantsCount];

    return myGrid;
  }

  static Map<int, List<Participant>> getGridForMainParticipants(
      {Map<String, Participant>? participants, Map<String, int>? gridInfo}) {
    List<Participant> currentParticipants = [];
    if (participants != null) {
      for (var element in participants.entries) {
        currentParticipants.add(element.value);
      }
    }
    Map<int, List<Participant>> columns = {};
    List<Participant>? participantList = [];

    for (int index = 0; index < gridInfo!.length - 2; index++) {
      int? columnForCurrentRow = gridInfo['r$index'];

      if (index == 0) {
        columns[index] = currentParticipants.sublist(0, columnForCurrentRow);
        currentParticipants.sublist(0, columnForCurrentRow).forEach((element) {
          participantList.add(element);
        });
      } else {
        columns[index] = currentParticipants.sublist(
            participantList.length, participantList.length + columnForCurrentRow!);
        currentParticipants
            .sublist(participantList.length, participantList.length + columnForCurrentRow)
            .forEach((element) {
          participantList.add(element);
        });
      }
    }
    return columns;
  }
}
