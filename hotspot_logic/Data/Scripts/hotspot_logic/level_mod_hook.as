string[] g_queued_dialogues;
bool g_is_dialogue_queue_backlogged = false;
float g_dialogue_queue_backlog_end_time = 0.0f;

const float k_dialogue_queue_combat_backlog_duration = 5.0f;

void Init(string level_name) {
}

void Update(int is_paused) {
    if(g_queued_dialogues.length() > 0) {
        string dialogue_name = g_queued_dialogues[g_queued_dialogues.length() - 1];

        if(TryToPlayDialogue(dialogue_name)) {
            g_queued_dialogues.removeLast();
        }
    }

    // For debugging
    // if(GetInputPressed(0, "o")) {
    //     for(int i = 0; i < GetNumHotspots(); i++) {
    //         Hotspot@ hotspot = ReadHotspot(i);

    //         if(hotspot.GetTypeString() == "hotspot_logic") {
    //             Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());
    //             hotspot_obj.ReceiveScriptMessage("hotspot_logic_log_state");
    //         }
    //     }
    // }
}

void ReceiveMessage(string message) {
    TokenIterator token_iter;
    token_iter.Init();

    if(!token_iter.FindNextToken(message)) {
        return;
    }

    string token = token_iter.GetToken(message);

    // if(token != "tutorial" && token != "added_object" && token != "notify_deleted") {
    //     Log(warning, "------------------------------- LEVEL HOOK GOT MESSAGE: " + message);
    // }

    if(token == "notify_deleted") {
        if(token_iter.FindNextToken(message)) {
            int delete_id = atoi(token_iter.GetToken(message));
            Object@ deleted_obj = ReadObjectFromID(delete_id);

            if(deleted_obj.GetType() == _hotspot_object) {
                Hotspot@ hotspot = cast<Hotspot@>(deleted_obj);

                if(hotspot.GetTypeString() == "hotspot_logic") {
                    deleted_obj.ReceiveScriptMessage("hotspot_logic_notify_deleted");
                }
            }
        }
    } else if(token == "character_knocked_out" || token == "character_died") {
        for(int i = 0; i < GetNumHotspots(); i++) {
            Hotspot@ hotspot = ReadHotspot(i);

            if(hotspot.GetTypeString() == "hotspot_logic") {
                ReadObjectFromID(hotspot.GetID()).ReceiveScriptMessage("hotspot_logic_" + message);
            }
        }
    } else if(token == "hotspot_logic_queue_dialogue") {
        if(token_iter.FindNextToken(message)) {
            if(!EditorModeActive()) {  // Doesn't queue if editor is active to make modding less annoying
                string dialogue_name = token_iter.GetToken(message);
                g_queued_dialogues.insertLast(dialogue_name);
            }
        } else {
            Log(warning, "hotspot_logic_queue_dialogue message malformed: " + message);
        }
    }
}

bool TryToPlayDialogue(string dialogue_name) {
    // Exit early if backlog timer is active
    if(g_is_dialogue_queue_backlogged) {
        if(g_dialogue_queue_backlog_end_time > the_time) {
            return false;
        }

        // Timer ended so clear it
        g_is_dialogue_queue_backlogged = false;
        g_dialogue_queue_backlog_end_time = 0.0f;
    }

    bool player_in_valid_state = true;

    for(int i = 0, len=GetNumCharacters(); i < len; i++) {
        MovementObject@ mo = ReadCharacter(i);

        if(mo.controlled && mo.QueryIntFunction("int CanPlayDialogue()") != 1) {
            g_is_dialogue_queue_backlogged = true;
            g_dialogue_queue_backlog_end_time = the_time + k_dialogue_queue_combat_backlog_duration;
            player_in_valid_state = false;
            break;
        }
    }

    if(player_in_valid_state) {
        level.SendMessage("start_dialogue \"" + dialogue_name + "\"");
    }

    return player_in_valid_state;
}

void DrawGUI() {
}

void SetWindowDimensions(int width, int height) {
}
