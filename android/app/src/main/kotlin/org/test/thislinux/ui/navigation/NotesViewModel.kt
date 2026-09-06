package org.test.thislinux.ui.navigation

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import org.test.thislinux.data.NoteItem
import org.test.thislinux.data.NotesRepository

class NotesViewModel(
    application: Application
) : AndroidViewModel(application) {

    private val repository =
        NotesRepository(application.applicationContext)

    private val _notes = MutableStateFlow<List<NoteItem>>(emptyList())
    val notes: StateFlow<List<NoteItem>> = _notes.asStateFlow()

    init {
        load()
    }

    private fun load() {
        viewModelScope.launch(Dispatchers.IO) {
            _notes.value = repository.loadNotes()
        }
    }

    fun addNote(
        title: String,
        content: String
    ) {
        if (title.isBlank() && content.isBlank()) return

        val note = NoteItem(
            title = title.trim(),
            content = content.trim(),
            createdAt = System.currentTimeMillis()
        )

        val updated = _notes.value + note

        _notes.value = updated

        viewModelScope.launch(Dispatchers.IO) {
            repository.saveNotes(updated)
        }
    }

    fun deleteNote(note: NoteItem) {
        val updated = _notes.value.filterNot {
            it == note
        }

        _notes.value = updated

        viewModelScope.launch(Dispatchers.IO) {
            repository.saveNotes(updated)
        }
    }
}
