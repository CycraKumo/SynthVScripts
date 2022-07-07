function getClientInfo() {
  return {
    "name" : "Duration Change (Javascript)",
    "category" : "Shikigami",
    "author" : "Shikigami",
    "versionNumber" : 1,
    "minEditorVersion" : 65537
  };
}

function main() {
    var myForm = {
        "title" : "タイミング調整",
        "message" : "「タメ」を作りたいときは子音を長く、母音を短く",
        "buttons" : "YesNoCancel",
        "widgets" : [
            {
                "name" : "sl1", "type" : "Slider",
                "label" : "子音の長さ",
                "format" : "%1.0f",
                "minValue" : 20,
                "maxValue" : 180,
                "interval" : 5,
                "default" : 140
            },
            {
                "name" : "sl2", "type" : "Slider",
                "label" : "母音の長さ",
                "format" : "%1.0f",
                "minValue" : 20,
                "maxValue" : 180,
                "interval" : 5,
                "default" : 60
            },
        ]
    };

    var result = SV.showCustomDialog(myForm);

    if(result.status == "Yes") {
        // Get the current selection, scope (group reference) and its target group.
        var selection = SV.getMainEditor().getSelection();
        var selectedNotes = selection.getSelectedNotes();
        var scope = SV.getMainEditor().getCurrentGroup();
        var group = scope.getTarget();

        if(selectedNotes.length < 1) {
            SV.showMessageBox("Error", "ノートを選択してください");
            SV.finish();
            return;
        }

        var sl1 = result.answers.sl1 / 100;
        var sl2 = result.answers.sl2 / 100;
        // No note or only one note is selected.

        // 選択したノートをぶん回して、タイミングを調整する。
        // あとはくろす兄貴の動画を見て、タイミング調整をするかしないかを決めると良いぞ。
        // 残り未実装　＝＞　長短長短……と音素を見るやつ。あと跳躍時。
        // 今実装できたもの　＝＞　選択されたノートのうち、隣り合っている4分音符のものをスライダで設定したタイミングに設定する。

        // シンプルに。どシンプルに考えよう。
        // タイミングをいじってタメを意図的に作りたい。それはわかる。
        // じゃあどうする？　どうすればタメになる？
        // 指定の音素を持ったノートの子音と、その1個前の母音をスライダーで設定した値に変更する必要がある。

        if(selectedNotes.length > 1) {
            for(var i = 0; i < selectedNotes.length; i ++) {
                if(i > 0){
                    // 隣り合ったノート
                    if(selectedNotes[i].getOnset() == selectedNotes[i - 1].getEnd()){
                        // 音素が○○なら
                        var trim = SV.getPhonemesForGroup(scope)[i];
                        if(trim.length > 1){
                            var keyword = trim.split(/\s+/)[0];
                            if(keyword == 'k' || keyword == 's' || keyword == 't' || keyword == 'n' || keyword == 'm' || keyword == 'p' || keyword == 'sh'){
                                // 選択されているノートのうち最後のノート
                                if (i == selectedNotes.length - 1) {
                                    selectedNotes[i - 1].setAttributes({
                                        dur: [sl1, sl2]
                                    })
                                    selectedNotes[i].setAttributes({
                                        dur: [sl1, 1],
                                    });
                                }
                                // ここがメイン
                                else{
                                    selectedNotes[i - 1].setAttributes({
                                        dur: [sl1, sl2]
                                    })
                                    selectedNotes[i].setAttributes({
                                        dur: [sl1, sl2],
                                    });
                                }
                            }
                        }
                    }
                }

                // var dur = selectedNotes[i].getAttributes().dur;
                // SV.showMessageBox("Filled Form", "selectedNotes"+i+" dur: " + dur);
            }
        }
        else {
            selectedNotes[0].setAttributes({
                dur: [sl1, sl2],
            });
        }


        // SV.showMessageBox("Filled Form", "Slider1 value: " + sl1);
        // SV.showMessageBox("Filled Form", "Slider2 value: " + sl2);
    }
    SV.finish();
}
