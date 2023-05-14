-- スクリプトの情報
function getClientInfo()
  return {
    name = "Duration 150 (Lua)",
    category = "Shikigami",
    author = "Shikigami",
    versionNumber = 0,
    minEditorVersion = 0
  }
end

function main()

    -- ここから
    local mainEditor = SV:getMainEditor()
    local mainEditorSelection = mainEditor:getSelection()
    -- ここまでおまじないみたいなもん
    -- 選択されているノートの全取得
    local allNotesSelected = mainEditorSelection:getSelectedNotes()

    -- 中身は1からスタートするので、選択したノート全てに適応できるようにfor文を回す
    for i = 1, #allNotesSelected do

        -- ノートのデュレーションを150,100に変更する
        allNotesSelected[i]:setAttributes({
            dur = {1.5, 1.0}
        })
    end
    SV:finish()
end
