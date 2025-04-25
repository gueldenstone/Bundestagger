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

# Create sample categories
categories = [
  %{
    category_id: "cat-1",
    name: "Climate Change",
    description: "Discussions about environmental policies, carbon emissions, and climate action",
    # emerald-500
    color: "#10B981"
  },
  %{
    category_id: "cat-2",
    name: "Education",
    description: "Topics related to schools, universities, and educational policies",
    # blue-500
    color: "#3B82F6"
  },
  %{
    category_id: "cat-3",
    name: "Economy",
    description: "Discussions about budget, taxes, and economic policies",
    # amber-500
    color: "#F59E0B"
  },
  %{
    category_id: "cat-4",
    name: "Healthcare",
    description: "Topics related to health policies, hospitals, and medical care",
    # red-500
    color: "#EF4444"
  }
]

for category <- categories do
  case Documents.get_category(category.category_id) do
    nil -> Documents.create_category(category)
    _ -> :ok
  end
end

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
