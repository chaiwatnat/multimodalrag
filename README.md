# Knowledge Studio · Multimodal RAG

A local web app that embeds text, PDFs, images, audio, and video with Gemini Embedding 2, searches Supabase pgvector, and uses Gemini Flash to answer using the retrieved sources.

## Setup

1. Install Python 3.9 or newer. The app uses only the Python standard library; `requirement.txt` lists no third-party packages. To prepare an isolated environment, optionally run:

   ```sh
   python3 -m venv .venv
   source .venv/bin/activate
   python -m pip install -r requirement.txt
   ```

2. Obtain a [Gemini API key](https://aistudio.google.com/apikey).
3. If `.env` does not exist, copy `.env.example` to `.env`. Fill in `GEMINI_API_KEY`, `SUPABASE_URL`, and `SUPABASE_SERVICE_ROLE_KEY`. Use the **secret key** or legacy **service_role** key from the Supabase dashboard API settings. This key bypasses row-level security; keep it private and never put it in browser code or commit `.env`.
4. Start the server:

   ```sh
   python3 server.py
   ```

5. Open [http://127.0.0.1:8765](http://127.0.0.1:8765). Restart the server after editing `.env`. `GEMINI_ANSWER_MODEL` selects the Flash model; `PORT` changes the local port.

The Supabase schema was created through MCP in the `MultimodalRAG` project. For another project, run `supabase/schema.sql` in that project's SQL editor and update `SUPABASE_URL` and its key.

## Use

Choose files in **Add your files**, then click **Embed selected files**. You can select several files; each is processed separately. UTF-8 TXT, Markdown and CSV files are split into overlapping text chunks, each embedded separately. Images, PDFs, audio, and video are embedded directly as one item each. The UI reports any individual file failures.

Ask a question in the main panel. Gemini embeds the question and the Supabase `rag_match` function selects the four closest vectors. Gemini Flash receives the matching text or original media and generates an answer with numbered citations. The retrieved source names, similarity scores, and text excerpts appear below. Similarity is not a confidence score; verify answers against the original sources.

Supported files: TXT, MD, CSV, PNG, JPEG, PDF (up to six pages), MP3, WAV (up to 180 seconds), MP4, and MOV (up to 120 seconds). Google limits video embedding to 32 sampled frames and does not process a video's audio track for embeddings. Supported video codecs are H.264, H.265, AV1 and VP9. Files are limited to 8 MB by this app. The Gemini API enforces its media and token limits. Split longer material first. Text files are limited to 100 chunks.

## Data and privacy

The server runs only on `127.0.0.1`, with no sign-in, for personal local development. Do not expose it to a network. Source names, text chunks and embedding vectors are stored in Supabase. Original files are stored locally in `data/` so that matched media can be provided to Flash. Keep this folder: a media source cannot be used in an answer if its local original is missing. Deleting a source in the app removes its Supabase records and local file.

Files, questions and retrieved evidence are transmitted to Google for embedding and answering; Supabase stores the index. API usage may incur charges. See [Gemini pricing](https://ai.google.dev/gemini-api/docs/pricing/). The app is a prototype, with no multi-user authentication, background indexing, ingestion queue, or production-scale vector index.
