
class CloudStorageException implements Exception{
    const CloudStorageException();
}

class CouldNotCreateNoteException extends CloudStorageException{}
class CouldNoGetAllNotesException extends CloudStorageException{}
class CouldNotUpdateNoteException extends CloudStorageException{}
class CouldNotDeleteNoteException extends CloudStorageException{}