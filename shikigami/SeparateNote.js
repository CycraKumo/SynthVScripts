function getClientInfo() {
  return {
    "name": "SeparateNote (Javascript)",
    "category": "Shikigami",
    "author": "Shikigami",
    "versionNumber": 1,
    "minEditorVersion": 65537
  };
}

function getTranslations(langCode) {
  if(langCode == "ja-jp") {
    return [
      ["Split and Make Note", "ノートを分割する"]
    ];
  }
  return [];
}

function main() {
  // Get the current selection, scope (group reference) and its target group.
  var selection = SV.getMainEditor().getSelection();
  var selectedNotes = selection.getSelectedNotes();
  var scope = SV.getMainEditor().getCurrentGroup();
  var group = scope.getTarget();

  // Get the current playhead position relative to the current group.
  var playhead = SV.getPlayback().getPlayhead();
  var timeAxis = SV.getProject().getTimeAxis();
  var playheadBlicks = timeAxis.getBlickFromSeconds(playhead)
    - scope.getTimeOffset();

  for(var i = 0; i < selectedNotes.length; i ++) {
    var note = selectedNotes[i];
    var originalOnset = note.getOnset();
    var originalEnd = note.getEnd();
    var fullDuration = note.getDuration();

    // Skip very short notes.
    // if(fullDuration < SV.QUARTER / 16)
    //   continue;

    // Split in the middle by default.
    var durationLeft = Math.round(note.getDuration() / 2);
    // Split at playhead position if intersects.
    if(playheadBlicks > originalOnset && playheadBlicks < originalEnd)
      durationLeft = playheadBlicks - originalOnset;

    // The left note after splitting.
    note.setDuration(durationLeft);
    // The right note after splitting.
    var splitted = SV.create("Note");
    splitted.setPitch(note.getPitch());
    splitted.setTimeRange(note.getEnd(), originalEnd - note.getEnd());

    // ここから
    splitted.setLyrics(note.getLyrics());
    group.addNote(splitted);
    selection.selectNote(splitted);

    break;
  }

  SV.finish();
}
