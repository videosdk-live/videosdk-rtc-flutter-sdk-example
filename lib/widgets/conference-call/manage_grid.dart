import 'package:videosdk/videosdk.dart';

enum device_type { mobile, tablet, desktop }

class ManageGrid {
  static Map<String, int>? getGridRowsAndColumns({
    required int participantsCount,
    required device_type device,
    bool isPresenting = false,
  }) {
    // if (isPresenting) {
    //   int r = participantsCount;
    //   const c = 1;

    //   const rows = {};

    //   for (int index = 0; index < participantsCount; index++) {
    //     rows['r${index}'] = 1;
    //   }

    //   return {r, c, ...rows};
    // }

    final mobilePortrait = {
      1: {'r': 1, 'c': 1, 'r0': 1},
      2: {'r': 1, 'c': 2, 'r0': 2},
      3: {'r': 2, 'c': 2, 'r0': 2, 'r1': 1},
      4: {'r': 2, 'c': 2, 'r0': 2, 'r1': 2},
      5: {'r': 3, 'c': 2, 'r0': 2, 'r1': 2, 'r2': 1},
      6: {'r': 3, 'c': 3, 'r0': 2, 'r1': 2, 'r2': 2},
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
    int maxCount = 0;

    if (device == device_type.mobile) {
      grid = mobilePortrait;
      maxCount = 6;
    } else if (device == device_type.tablet) {
      grid = tabPortrait;
      maxCount = 7;
    } else if (device == device_type.desktop) {
      grid = smallDesktop;
      maxCount = 7;
    }

    grid = smallDesktop;
    maxCount = 16;

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
        print("currentParticipants ${element.value.displayName}");
      }
    }
    Map<int, List<Participant>> columns = {};
    List<Participant>? buckets = [];

    for (int index = 0; index < gridInfo!.length - 2; index++) {
      int? columnForCurrentRow = gridInfo['r$index'];
      print('columnForCurrentRow ${columnForCurrentRow}');

      if (index == 0) {
        columns[index] = currentParticipants.sublist(0, columnForCurrentRow);
        currentParticipants.sublist(0, columnForCurrentRow).forEach((element) {
          buckets!.add(element);
        });
      } else {
        columns[index] = currentParticipants.sublist(
            buckets.length, buckets.length + columnForCurrentRow!);
        currentParticipants
            .sublist(buckets!.length, buckets.length + columnForCurrentRow!)
            .forEach((element) {
          buckets.add(element);
        });
      }
    }

    columns.forEach((key, value) {
      print("particiapnt key $key");
      value.forEach((element) {
        print("particiapnt ${element.displayName}");
      });
    });
    return columns;
  }
}
