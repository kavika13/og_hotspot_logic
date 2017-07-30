enum DrawLifetime {
    // TODO: Can we somehow get these from the constants? Seems to be giving me negative values
    //       In the mean time, have to be careful to keep them up to date
    kDeleteOnDrawDrawLifetime = 0,  // _delete_on_draw
    kDeleteOnUpdateDrawLifetime = 1,  // _delete_on_update
    kFadeDrawLifetime = 2,  // _fade
    kPersistentDrawLifetime = 3,  // _persistent
};

void DrawDiskIcon(mat4 &in transform, vec4 color, DrawLifetime lifetime) {
    vec3[] disk_icon_lines = {
        // Body
        vec3(-1.0f, 1.0f, 0.0f), vec3(1.0f, 1.0f, 0.0f),    // Top
        vec3(-1.0f, -1.0f, 0.0f), vec3(1.0f, -1.0f, 0.0f),  // Bottom
        vec3(-1.0f, 1.0f, 0.0f), vec3(-1.0f, -1.0f, 0.0f),  // Left
        vec3(1.0f, 1.0f, 0.0f), vec3(1.0f, -1.0f, 0.0f),    // Right

        // Read shield
        vec3(-0.6f, 1.0f, 0.0f), vec3(-0.6f, 0.2f, 0.0f),  // Left
        vec3(-0.6f, 0.2f, 0.0f), vec3(0.6f, 0.2f, 0.0f),   // Bottom
        vec3(0.6f, 0.2f, 0.0f), vec3(0.6f, 1.0f, 0.0f),    // Right

        // Read slot
        vec3(0.2f, 0.8f, 0.0f), vec3(0.4f, 0.8f, 0.0f),  // Top
        vec3(0.2f, 0.4f, 0.0f), vec3(0.4f, 0.4f, 0.0f),  // Bottom
        vec3(0.2f, 0.8f, 0.0f), vec3(0.2f, 0.4f, 0.0f),  // Left
        vec3(0.4f, 0.8f, 0.0f), vec3(0.4f, 0.4f, 0.0f),  // Right

        // Read shield
        vec3(-0.8f, -1.0f, 0.0f), vec3(-0.8f, 0.0f, 0.0f),  // Left
        vec3(-0.8f, 0.0f, 0.0f), vec3(0.8f, 0.0f, 0.0f),    // Top
        vec3(0.8f, 0.0f, 0.0f), vec3(0.8f, -1.0f, 0.0f),    // Right
    };

    for(uint i = 0, len = disk_icon_lines.length(); i < len; i++) {
        disk_icon_lines[i] = transform * disk_icon_lines[i];
    }

    DebugDrawLines(disk_icon_lines, color, int(lifetime));
}
