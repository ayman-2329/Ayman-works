import os
from typing import List, Optional
import numpy as np
import faiss
from sentence_transformers import SentenceTransformer
from langchain_community.document_loaders import TextLoader, DirectoryLoader


class RAGSystem:
    def __init__(self, docs_path: str, model_name: str = 'all-MiniLM-L6-v2') -> None:
        """
        Initialize RAG system with document directory and embedding model.
        """
        self.docs_path = docs_path
        self.model = SentenceTransformer(model_name)
        self.documents = []  # List of documents loaded
        self.texts: List[str] = []  # Extracted texts from documents
        self.embeddings: Optional[np.ndarray] = None
        self.index: Optional[faiss.IndexFlatL2] = None
        self._load_documents()
        self._build_index()

    def _load_documents(self) -> None:
        """
        Load text documents from directory recursively.
        """
        loader = DirectoryLoader(self.docs_path, glob="**/*.txt")
        self.documents = loader.load()
        self.texts = [doc.page_content for doc in self.documents]

    def _build_index(self) -> None:
        """
        Build FAISS index from document embeddings.
        """
        if not self.texts:
            self.index = None
            self.embeddings = None
            return

        self.embeddings = self.model.encode(self.texts, convert_to_numpy=True)
        dim = self.embeddings.shape[1]
        self.index = faiss.IndexFlatL2(dim)
        self.index.add(self.embeddings)

    def query(self, question: str, top_k: int = 3) -> str:
        """
        Query the RAG system with a question and return top_k similar documents' text.
        """
        if self.index is None or self.embeddings is None:
            return "No documents available for querying."

        question_embedding = self.model.encode([question], convert_to_numpy=True)
        top_k = min(top_k, len(self.texts))  # Cap top_k to available docs
        distances, indices = self.index.search(question_embedding, top_k)
        results = [self.texts[idx] for idx in indices[0] if idx < len(self.texts)]
        return "\n\n".join(results)

    def add_document(self, doc_path: str) -> None:
        """
        Add a new document to the index.
        """
        loader = TextLoader(doc_path)
        new_docs = loader.load()
        new_texts = [doc.page_content for doc in new_docs]

        if not new_texts:
            return  # Nothing to add

        self.texts.extend(new_texts)

        new_embeddings = self.model.encode(new_texts, convert_to_numpy=True)
        if self.embeddings is not None:
            self.embeddings = np.vstack([self.embeddings, new_embeddings])
        else:
            self.embeddings = new_embeddings

        if self.index is None:
            dim = self.embeddings.shape[1]
            self.index = faiss.IndexFlatL2(dim)

        self.index.add(new_embeddings)
