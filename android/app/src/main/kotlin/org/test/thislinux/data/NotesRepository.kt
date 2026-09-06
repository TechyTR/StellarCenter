package org.test.thislinux.data

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

class NotesRepository(
    private val context: Context
) {

    companion object {
        private const val PREFS_NAME = "stellar_center"
        private const val NOTES_KEY = "notes_list"
    }

    private val preferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun loadNotes(): List<NoteItem> {
        val raw = preferences.getString(NOTES_KEY, null)
            ?: return emptyList()

        return try {
            val array = JSONArray(raw)

            buildList {
                for (i in 0 until array.length()) {
                    val item = array.getJSONObject(i)

                    add(
                        NoteItem(
                            title = item.optString("title"),
                            content = item.optString("content"),
                            createdAt = item.optLong("createdAt")
                        )
                    )
                }
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    fun saveNotes(notes: List<NoteItem>) {
        val array = JSONArray()

        notes.forEach { note ->
            array.put(
                JSONObject().apply {
                    put("title", note.title)
                    put("content", note.content)
                    put("createdAt", note.createdAt)
                }
            )
        }

        preferences
            .edit()
            .putString(NOTES_KEY, array.toString())
            .apply()
    }
}
