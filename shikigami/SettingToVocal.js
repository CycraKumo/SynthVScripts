function getClientInfo() {
  return {
    "name" : "SettingToVocal (Javascript)",
    "category" : "Shikigami",
    "author" : "Shikigami",
    "versionNumber" : 1,
    "minEditorVersion" : 65537
  };
}

var vocalModeDictionary = {
    "An Xiao": ["Airy", "Chest", "Open", "Power", "Soft"], // 5
    "ANRI": ["Emotive", "Charm", "Chill", "Light"], // 4
    "ASTERIAN": ["Clear", "Warm", "Gentle", "Strained", "Rough", "Open", "Closed", "Passionate", "Theatrical"], // 9
    "Cheng Xiao": ["Open", "Closed", "Resonant"], // 3
    "Cong Zheng": ["Soft", "Gentle", "Closed", "Vivid", "Solid", "Powerful"], // 6
    "Eleanor Forte": ["Melancholic", "Solid", "Warm", "Powerful", "Dark", "Clear", "Tender", "Bold"], // 8
    "Feng Yi": ["Chest", "Power", "Open", "Opera", "Soft", "Airy"], // 6
    "Chifuyu": ["Kawaii", "Soft", "Rock", "Adult", "Piano_Ballade"], // 5
    "JUN": ["Dark", "Chest", "Soul", "Power", "Light", "Tsubaki", "Soft"], // 7
    "Rikka": ["Kawaii", "Soft", "Pops", "Emotional", "Ballade"], // 5
    "Kevin": ["Belt", "Clear", "Soft", "Solid"], // 4
    "Seika": ["Breathy", "Bright", "Straight", "Tight"], // 4
    "Mai": ["Emotional", "Soft"], // 2
    "MEDIUM5 Stardust": ["Airy", "Bright", "Cool", "Dark", "Emotional", "Power", "Solid", "Sweet"], // 8
    "Mo Chen": ["Open", "Soft", "Clear"], // 3
    "Natalie": ["Soft", "Soulful", "Steady", "Bold", "Warm"], // 5
    "Karin": ["Kawaii", "Soft", "Cool", "Happy", "Falsetto"], // 5
    "Ninezero": ["Solid", "Overdrive", "Muted"], // 3
    "Qing Su": ["Airy", "Chest", "Power", "Soft", "Sweet"], // 5
    "Ryo": ["Open", "Soft", "Airy", "Clear", "Nasal", "Resonant"], // 6
    "Saki": ["Chest", "Airy", "Open", "Soft"], // 4
    "SOLARIA": ["Clear", "Soft", "Airy", "Power", "Passionate", "Solid", "Light"], // 7
    "Tsuina": ["Attacky", "Breathy", "Crispy", "Soft"], // 4
    "Maki": ["Adult", "Breathy", "Power_Pop", "Twangy", "Whisper"], // 5
    "Weina": ["Delicate", "Tender", "Lucid", "Firm", "Powerful", "Resonant", "Warm"], // 7
    "Xia Yu Yao": ["Dark", "Soft", "Solid", "Whisper", "Sweet"], // 5
    "Xuan Yu": ["Soft", "Light", "Passionate", "Solid", "Open"], // 5
    "Yuma": ["Gentle", "Airy", "Powerful", "Solid"], // 4
};

function main() {

    // 現在選択しているトラックをデフォルト値にしながらトラック一覧をコンボボックスに表示する処理。
    project = SV.getProject();

    tracks = project.getNumTracks();

    choices = [];
    flgArray = ["singer", "note", "automation"];

    defaultTrack = 0;

    currentTrack = SV.getMainEditor().getCurrentTrack();

    currentName = currentTrack.getName();

    regex = /Setting/

    count = 0;

    defaultPitch = 26;

    for (var i = 0; i < tracks; i++) {
        trackName = project.getTrack(i).getName()
        if (regex.test(trackName)){
            choices.push(trackName);
            if (trackName == currentName) defaultTrack = count;
            count++;
        }
    }

    var myForm = {
        "title": "設定トラック情報反映",
        "message": "情報を反映する設定トラックを選ぶ",
        "buttons": "YesNoCancel",
        "widgets": [
            {
                "name": "cb1",
                "type": "ComboBox",
                "label": "Select Track",
                "choices": choices,
                "default": defaultTrack
            },
            {
                "name": "cb2",
                "type": "ComboBox",
                "label": "Select Track",
                "choices": ["singer", "note", "automation"],
                "default": 0
            },
        ]
    };

    var result = SV.showCustomDialog(myForm);

    // そのオブジェクトが持っている属性の列挙
    function getFields(obj) {
        var result = [];
        for (var id in obj) {
            result.push(id + ": " + obj[id].toString());
        }
        return result;
    }

    if (result.status == "Yes") {
        // トラックの追加
        vocalTrackName = choices[result.answers.cb1]
        flgResult = result.answers.cb2
        flg = flgArray[flgResult]
        project = SV.getProject();
        numTrack = project.getNumTracks();
        trackCountArray = vocalTrackName.split("_");
        trackCount = trackCountArray[trackCountArray.length - 1];
        currentSettingTrack = ""

        reflectTrack = [];
        for (var i = 0; i < numTrack; i++) {
            trackName = project.getTrack(i).getName()

            if (trackName == vocalTrackName) currentSettingTrack = project.getTrack(i);
            trackCountCheckArray = trackName.split("_");
            trackCountCheck = trackCountCheckArray[trackCountCheckArray.length - 1]
            if (trackCountCheckArray[0] != 'Setting' && trackCount == trackCountCheck) reflectTrack.push(project.getTrack(i))
            if (trackCountCheckArray[0] == 'Setting' && trackCount == trackCountCheck) settingTrack = project.getTrack(i)
        }

        for (var i = 0; i < reflectTrack.length; i++) {
        // for (var i = 0; i < 1; i++) {
            // SV.showMessageBox("reflectTrack", "reflectTrack: " + reflectTrack[i].getName());
            // Settingの後ろの数字に紐づくトラックが取得できた。
            track = reflectTrack[i];
            reflectReference = track.getGroupReference(0);
            reflectTarget = reflectReference.getTarget();

            reflectName = track.getName();
            // 歌唱トラック、最初のノートの位置
            reflectOnset = reflectTarget.getNote(0).getOnset();

            // 歌唱トラック、duration
            reflectDuration = reflectReference.getDuration();

            // 歌唱トラック、最後のノートの右
            reflectEnd = reflectTarget.getNote(reflectTarget.getNumNotes() - 1).getEnd();

            // 設定トラック
            settingReference = settingTrack.getGroupReference(1);

            settingTarget = settingReference.getTarget();

            settingNumNote = settingTarget.getNumNotes();

            reflectNoteCounter = 0;

            lastVocal9 = 0;
            lastVocal8 = 0;
            lastVocal7 = 0;
            lastVocal6 = 0;
            lastVocal5 = 0;
            lastVocal4 = 0;
            lastVocal3 = 0;
            lastVocal2 = 0;
            lastVocal1 = 0;
            lastToneShift = 0;
            lastGender = 0;
            lastVoicing = 0;
            lastBreathiness = 0;
            lastTension = 0;
            lastLoudness = 0;
            lastVibratoEnv = 0;
            lastPitchDelta = 0;

            // ノートとそれ以外を分けた方がいい気がする。

            // 今のこのやり方は、設定トラックの情報を全部見て、それに対応したものを探そうとしているけど、
            // そうじゃなくて、反映したいトラックが個々にあるからそれに一致する設定トラックの情報を取ってきてみたいなやり方のほうがいい気がする
            // ノート部分に関してはそれが通用するんだし。
            // 場所はonsetで見つける。

            // 184行目、settingNumNoteの部分を別のものにできそう。例えばノートに関係する部分なんてsettingという観点からしたら44-63の間しかないわけだし。
            // 実際の数にすると更に減って18個とかだし。

            if (flg == "note") {
                count = 0;
                for (k = 0; k < reflectTarget.getNumNotes(); k++) {
                    reflectNote = reflectTarget.getNote(k);
                    reflectOnset = reflectNote.getOnset();
                    for (l = count; l < settingNumNote; l++) {
                        settingNote = settingTarget.getNote(l);
                        if (reflectOnset == settingNote.getOnset()) {
                            switch (settingNote.getPitch()) {
                                case 44:
                                    //表現グループ
                                    reflectNote.setAttributes({
                                        "exprGroup": settingNote.getLyrics(),
                                    });
                                    break;
                                case 45:
                                    //強さ
                                    reflectNote.setAttributes({
                                        "strength": settingNote.getLyrics().split(" "),
                                    });
                                    break;
                                case 46:
                                    //音素長さ
                                    reflectNote.setAttributes({
                                        "dur": settingNote.getLyrics().split(" "),
                                    });
                                    break;
                                case 47:
                                    //代替音素
                                    reflectNote.setAttributes({
                                        "alt": settingNote.getLyrics().split(" "),
                                    });
                                    break;
                                case 48:
                                    //音素
                                    reflectNote.setPhonemes(settingNote.getLyrics());
                                    break;
                                case 49:
                                    //ノートオフセット
                                    reflectNote.setAttributes({
                                        "tNoteOffset": settingNote.getLyrics(),
                                    });
                                    break;
                                case 51:
                                    //ゆらぎ
                                    reflectNote.setAttributes({
                                        "dF0Jitter": settingNote.getLyrics(),
                                    });
                                    break;
                                case 52:
                                    //位相
                                    reflectNote.setAttributes({
                                        "pF0Vbr": settingNote.getLyrics(),
                                    });
                                    break;
                                case 53:
                                    //周波数
                                    reflectNote.setAttributes({
                                        "fF0Vbr": settingNote.getLyrics(),
                                    });
                                    break;
                                case 54:
                                    //深さ
                                    reflectNote.setAttributes({
                                        "dF0Vbr": settingNote.getLyrics(),
                                    });
                                    break;
                                case 55:
                                    //右
                                    reflectNote.setAttributes({
                                        "tF0VbrRight": settingNote.getLyrics(),
                                    });
                                    break;
                                case 56:
                                    //左
                                    reflectNote.setAttributes({
                                        "tF0VbrLeft": settingNote.getLyrics(),
                                    });
                                    break;
                                case 57:
                                    //開始タイミング
                                    reflectNote.setAttributes({
                                        "tF0VbrStart": settingNote.getLyrics(),
                                    });
                                    break;
                                case 59:
                                    //深さ - 右
                                    reflectNote.setAttributes({
                                        "dF0Right": settingNote.getLyrics(),
                                    });
                                    break;
                                case 60:
                                    //深さ - 左
                                    reflectNote.setAttributes({
                                        "dF0Left": settingNote.getLyrics(),
                                    });
                                    break;
                                case 61:
                                    //長さ - 右
                                    reflectNote.setAttributes({
                                        "tF0Right": settingNote.getLyrics(),
                                    });
                                    break;
                                case 62:
                                    //長さ - 左
                                    reflectNote.setAttributes({
                                        "tF0Left": settingNote.getLyrics(),
                                    });
                                    break;
                                case 63:
                                    //タイミング
                                    reflectNote.setAttributes({
                                        "tF0Offset": settingNote.getLyrics(),
                                    });
                                    break;
                            }
                            count = l;
                        }
                    }
                }
            }
            else if(flg == "singer") {
                for (var j = 0; j < settingNumNote; j++) {
                    settingNote = settingTarget.getNote(j);
                    // ノートの取られ方は左下から上→右の順
                    if (settingNote.getOnset() >= reflectOnset && settingNote.getEnd() <= reflectEnd + SV.QUARTER) {
                        switch (settingNote.getPitch()) {
                            case 26:
                                //周波数
                                reflectReference.setVoice({
                                    "fF0Vbr": settingNote.getLyrics(),
                                });
                                break;
                            case 27:
                                //深さ
                                reflectReference.setVoice({
                                    "dF0Vbr": settingNote.getLyrics(),
                                });
                                break;
                            case 28:
                                //右
                                reflectReference.setVoice({
                                    "tF0VbrRight": settingNote.getLyrics(),
                                });
                                break;
                            case 29:
                                //左
                                reflectReference.setVoice({
                                    "tF0VbrLeft": settingNote.getLyrics(),
                                });
                                break;
                            case 30:
                                //開始タイミング
                                reflectReference.setVoice({
                                    "tF0VbrStart": settingNote.getLyrics(),
                                });
                                break;
                            case 32:
                                //深さ - 右
                                reflectReference.setVoice({
                                    "dF0Right": settingNote.getLyrics(),
                                });
                                break;
                            case 33:
                                //深さ - 左
                                reflectReference.setVoice({
                                    "dF0Left": settingNote.getLyrics(),
                                });
                                break;
                            case 34:
                                //長さ - 右
                                reflectReference.setVoice({
                                    "tF0Right": settingNote.getLyrics(),
                                });
                                break;
                            case 35:
                                //長さ - 左
                                reflectReference.setVoice({
                                    "tF0Left": settingNote.getLyrics(),
                                });
                                break;
                            case 37:
                                //トーンシフト
                                reflectReference.setVoice({
                                    "paramToneShift": settingNote.getLyrics(),
                                });
                                break;
                            case 38:
                                //ジェンダー
                                reflectReference.setVoice({
                                    "paramGender": settingNote.getLyrics(),
                                });
                                break;
                            case 39:
                                //ブレス
                                reflectReference.setVoice({
                                    "paramBreathiness": settingNote.getLyrics(),
                                });
                                break;
                            case 40:
                                //テンション
                                reflectReference.setVoice({
                                    "paramTension": settingNote.getLyrics(),
                                });
                                break;
                            case 41:
                                //ラウドネス
                                reflectReference.setVoice({
                                    "paramLoudness": settingNote.getLyrics(),
                                });
                                break;

                        }
                    }
                }
            }
            else if (flg == "automation") {
                for (var j = 0; j < settingNumNote; j++) {
                    settingNote = settingTarget.getNote(j);
                    // ノートの取られ方は左下から上→右の順
                    if (settingNote.getOnset() >= reflectOnset && settingNote.getEnd() <= reflectEnd + SV.QUARTER) {
                        switch (settingNote.getPitch()) {
                            case 66:
                                // 9
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][8]
                                ).add(settingNote.getOnset(), lastVocal9);
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][8]
                                ).add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastVocal9 = settingNote.getLyrics()
                                break;
                            case 67:
                                // 8
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][7]
                                ).add(settingNote.getOnset(), lastVocal8);
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][7]
                                ).add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastVocal8 = settingNote.getLyrics()
                                break;
                            case 68:
                                // 7
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][6]
                                ).add(settingNote.getOnset(), lastVocal7);
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][6]
                                ).add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastVocal7 = settingNote.getLyrics()
                                break;
                            case 69:
                                // 6
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][5]
                                ).add(settingNote.getOnset(), lastVocal6);
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][5]
                                ).add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastVocal6 = settingNote.getLyrics()
                                break;
                            case 70:
                                // 5
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][4]
                                ).add(settingNote.getOnset(), lastVocal5);
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][4]
                                ).add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastVocal5 = settingNote.getLyrics()
                                break;
                            case 71:
                                // 4
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][3]
                                ).add(settingNote.getOnset(), lastVocal4);
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][3]
                                ).add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastVocal4 = settingNote.getLyrics()
                                break;
                            case 72:
                                // 3
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][2]
                                ).add(settingNote.getOnset(), lastVocal3);
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][2]
                                ).add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastVocal3 = settingNote.getLyrics()
                                break;
                            case 73:
                                // 2
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][1]
                                ).add(settingNote.getOnset(), lastVocal2);
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][1]
                                ).add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastVocal2 = settingNote.getLyrics()
                                break;
                            case 74:
                                // 1
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][0]
                                ).add(settingNote.getOnset(), lastVocal1);
                                reflectTarget.getParameter(
                                    "vocalMode_" + vocalModeDictionary[reflectName.split("_")[0]][0]
                                ).add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastVocal1 = settingNote.getLyrics()
                                break;
                            case 76:
                                // トーンシフト
                                reflectTarget.getParameter("toneshift").add(settingNote.getOnset(), lastToneShift);
                                reflectTarget.getParameter("toneshift").add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastToneShift = settingNote.getLyrics()
                                break;
                            case 77:
                                // ジェンダー
                                reflectTarget.getParameter("gender").add(settingNote.getOnset(), lastGender);
                                reflectTarget.getParameter("gender").add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastGender = settingNote.getLyrics()
                                break;
                            case 78:
                                // 有声/無声音
                                reflectTarget.getParameter("voicing").add(settingNote.getOnset(), lastVoicing);
                                reflectTarget.getParameter("voicing").add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastVoicing = settingNote.getLyrics()
                                break;
                            case 79:
                                // ブレス
                                reflectTarget.getParameter("breathiness").add(settingNote.getOnset(), lastBreathiness);
                                reflectTarget.getParameter("breathiness").add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastBreathiness = settingNote.getLyrics()
                                break;
                            case 80:
                                // テンション
                                reflectTarget.getParameter("tension").add(settingNote.getOnset(), lastTension);
                                reflectTarget.getParameter("tension").add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastTension = settingNote.getLyrics()
                                break;
                            case 81:
                                // ラウドネス
                                reflectTarget.getParameter("loudness").add(settingNote.getOnset(), lastLoudness);
                                reflectTarget.getParameter("loudness").add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastLoudness = settingNote.getLyrics()
                                break;
                            case 82:
                                // ビブラートエンベロープ
                                reflectTarget.getParameter("vibratoEnv").add(settingNote.getOnset(), lastVibratoEnv);
                                reflectTarget.getParameter("vibratoEnv").add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastVibratoEnv = settingNote.getLyrics()
                                break;
                            case 83:
                                // ピッチベンド
                                reflectTarget.getParameter("pitchDelta").add(settingNote.getOnset(), lastPitchDelta);
                                reflectTarget.getParameter("pitchDelta").add(settingNote.getOnset() + 1, settingNote.getLyrics());
                                lastPitchDelta = settingNote.getLyrics()
                                break;
                        }
                    }
                }
            }
        }
    } else if (result.status == "No") {
        SV.showMessageBox("Filled Form", "Ctrl+Sで保存をしておくように。");
    }
    SV.finish();
}
