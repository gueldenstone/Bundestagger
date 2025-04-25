# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BundestagAnnotate.Repo.insert!(%BundestagAnnotate.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias BundestagAnnotate.Documents

# Create a sample document if it doesn't exist
document =
  case Documents.get_document("doc-1") do
    nil ->
      {:ok, doc} =
        Documents.create_document(%{
          document_id: "doc-1",
          date: ~D[2024-04-25],
          title: "Sample Parliamentary Debate",
          content: """
          The parliament convened today to discuss important matters of state.
          The first topic was climate change. Many members expressed concern about rising temperatures.
          The second topic was education reform. Several proposals were put forward.
          Finally, the budget was discussed. The finance minister presented the annual report.
          """
        })

      doc

    existing_doc ->
      existing_doc
  end

# Create sample excerpts if they don't exist
excerpts = [
  %{
    excerpt_id: "ex-1",
    document_id: document.document_id,
    sentence_before: "The parliament convened today to discuss important matters of state.",
    sentence_with_keyword: "The first topic was climate change.",
    sentence_after: "Many members expressed concern about rising temperatures."
  },
  %{
    excerpt_id: "ex-2",
    document_id: document.document_id,
    sentence_before: "The first topic was climate change.",
    sentence_with_keyword: "Many members expressed concern about rising temperatures.",
    sentence_after: "The second topic was education reform."
  },
  %{
    excerpt_id: "ex-3",
    document_id: document.document_id,
    sentence_before: "Several proposals were put forward.",
    sentence_with_keyword: "Finally, the budget was discussed.",
    sentence_after: "The finance minister presented the annual report."
  }
]

for excerpt <- excerpts do
  case Documents.get_excerpt(excerpt.excerpt_id) do
    nil -> Documents.create_excerpt(excerpt)
    _ -> :ok
  end
end
