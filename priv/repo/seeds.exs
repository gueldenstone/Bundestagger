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

alias BundestagAnnotate.{Documents, Categories}

# Create sample categories
categories = [
  %{
    name: "Climate Change",
    description: "Discussions about environmental policies, carbon emissions, and climate action",
    # emerald-500
    color: "#10B981"
  },
  %{
    name: "Education",
    description: "Topics related to schools, universities, and educational policies",
    # blue-500
    color: "#3B82F6"
  },
  %{
    name: "Economy",
    description: "Discussions about budget, taxes, and economic policies",
    # amber-500
    color: "#F59E0B"
  },
  %{
    name: "Healthcare",
    description: "Topics related to health policies, hospitals, and medical care",
    # red-500
    color: "#EF4444"
  }
]

# Create categories if they don't exist and collect their IDs
category_map =
  for category <- categories do
    case Categories.list_categories() |> Enum.find(&(&1.name == category.name)) do
      nil ->
        {:ok, created} = Categories.create_category(category)
        IO.puts("Created category: #{category.name} with ID: #{created.category_id}")
        {category.name, created.category_id}

      existing ->
        IO.puts("Found existing category: #{category.name} with ID: #{existing.category_id}")
        {category.name, existing.category_id}
    end
  end
  |> Map.new()

IO.puts("Category map: #{inspect(category_map)}")

# Create a sample document if it doesn't exist
document =
  case Documents.list_documents() |> Enum.find(&(&1.title == "Sample Parliamentary Debate")) do
    nil ->
      {:ok, doc} =
        Documents.create_document(%{
          date: ~D[2024-04-25],
          title: "Sample Parliamentary Debate",
          content: """
          The parliament convened today to discuss important matters of state.
          The first topic was climate change. Many members expressed concern about rising temperatures.
          The second topic was education reform. Several proposals were put forward.
          Finally, the budget was discussed. The finance minister presented the annual report.
          """
        })

      IO.puts("Created document with ID: #{doc.document_id}")
      doc

    existing_doc ->
      IO.puts("Found existing document with ID: #{existing_doc.document_id}")
      existing_doc
  end

# Create sample excerpts if they don't exist
excerpts = [
  %{
    document_id: document.document_id,
    category_id: category_map["Climate Change"],
    sentence_before: "The parliament convened today to discuss important matters of state.",
    sentence_with_keyword: "The first topic was climate change.",
    sentence_after: "Many members expressed concern about rising temperatures."
  },
  %{
    document_id: document.document_id,
    category_id: category_map["Climate Change"],
    sentence_before: "The first topic was climate change.",
    sentence_with_keyword: "Many members expressed concern about rising temperatures.",
    sentence_after: "The second topic was education reform."
  },
  %{
    document_id: document.document_id,
    category_id: category_map["Economy"],
    sentence_before: "Several proposals were put forward.",
    sentence_with_keyword: "Finally, the budget was discussed.",
    sentence_after: "The finance minister presented the annual report."
  }
]

# Create excerpts if they don't exist
for excerpt <- excerpts do
  IO.puts("Creating excerpt with:")
  IO.puts("  document_id: #{excerpt.document_id}")
  IO.puts("  category_id: #{excerpt.category_id}")
  IO.puts("  sentence: #{excerpt.sentence_with_keyword}")

  case Documents.list_excerpts_by_document(document.document_id)
       |> Enum.find(&(&1.sentence_with_keyword == excerpt.sentence_with_keyword)) do
    nil ->
      case Documents.create_excerpt(excerpt) do
        {:ok, created} ->
          IO.puts("Created excerpt with ID: #{created.excerpt_id}")
          IO.puts("  document_id: #{created.document_id}")
          IO.puts("  category_id: #{created.category_id}")

        {:error, error} ->
          IO.puts("Error creating excerpt: #{inspect(error)}")
          IO.puts("Full excerpt data: #{inspect(excerpt)}")
      end

    existing ->
      IO.puts("Found existing excerpt with ID: #{existing.excerpt_id}")
      IO.puts("  document_id: #{existing.document_id}")
      IO.puts("  category_id: #{existing.category_id}")
  end
end
