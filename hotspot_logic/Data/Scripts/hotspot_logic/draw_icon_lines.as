enum DrawLifetime {
    // TODO: Can we somehow get these from the constants? Seems to be giving me negative values
    //       In the mean time, have to be careful to keep them up to date
    kDeleteOnDrawDrawLifetime = 0,  // _delete_on_draw
    kDeleteOnUpdateDrawLifetime = 1,  // _delete_on_update
    kFadeDrawLifetime = 2,  // _fade
    kPersistentDrawLifetime = 3,  // _persistent
};

void DrawDiskIcon(const mat4 &in transform, const vec4 &in color, DrawLifetime lifetime) {
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

void DrawPlayIcon(const mat4 &in transform, const vec4 &in color, DrawLifetime lifetime) {
    vec3[] play_icon_lines = {
        vec3(-1.0f, 1.0f, 0.0f), vec3(1.0f, 0.0f, 0.0f),    // Top
        vec3(-1.0f, -1.0f, 0.0f), vec3(1.0f, 0.0f, 0.0f),  // Bottom
        vec3(-1.0f, 1.0f, 0.0f), vec3(-1.0f, -1.0f, 0.0f),  // Left
    };

    for(uint i = 0, len = play_icon_lines.length(); i < len; i++) {
        play_icon_lines[i] = transform * play_icon_lines[i];
    }

    DebugDrawLines(play_icon_lines, color, int(lifetime));
}

mat4 GetBillboardTransform(vec3 translation, vec3 rotation_normal, vec3 scale, const vec3 &in up_direction = vec3(0.0f, 1.0f, 0.0f)) {
    const vec3 right_direction = normalize(cross(rotation_normal, up_direction));
    const vec3 new_up_direction = cross(right_direction, rotation_normal);

    mat4 result_rotation;
    result_rotation.SetColumn(0, vec3(right_direction.x, right_direction.y, right_direction.z));
    result_rotation.SetColumn(1, vec3(new_up_direction.x, new_up_direction.y, new_up_direction.z));
    result_rotation.SetColumn(2, vec3(rotation_normal.x, rotation_normal.y, rotation_normal.z));

    mat4 result_scale;
    result_scale.SetColumn(0, vec3(scale.x, 0.0f, 0.0f));
    result_scale.SetColumn(1, vec3(0.0f, scale.x, 0.0f));
    result_scale.SetColumn(2, vec3(0.0f, 0.0f, scale.z));

    mat4 result_translation;
    result_translation.SetColumn(3, translation);

    return result_translation * result_scale * result_rotation;
}
