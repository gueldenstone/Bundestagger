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

defmodule SeedHelpers do
  def create_or_find(schema, attrs, find_by) do
    list_fn =
      case schema do
        Categories -> &Categories.list_categories/0
        Documents -> &Documents.list_documents/0
      end

    create_fn =
      case schema do
        Categories -> &Categories.create_category/1
        Documents -> &Documents.create_document/1
      end

    case list_fn.() |> Enum.find(&(Map.get(&1, find_by) == Map.get(attrs, find_by))) do
      nil ->
        case create_fn.(attrs) do
          {:ok, created} ->
            IO.puts("Created #{inspect(schema)} with ID: #{Map.get(created, :id)}")
            created

          {:error, error} ->
            IO.puts("Error creating #{inspect(schema)}: #{inspect(error)}")
            nil
        end

      existing ->
        IO.puts("Found existing #{inspect(schema)} with ID: #{Map.get(existing, :id)}")
        existing
    end
  end
end

# Seed data definitions
seed_data = %{
  categories: [
    %{
      name: "Climate Change",
      description:
        "Discussions about environmental policies, carbon emissions, and climate action",
      color: "#10B981"
    },
    %{
      name: "Education",
      description: "Topics related to schools, universities, and educational policies",
      color: "#3B82F6"
    },
    %{
      name: "Economy",
      description: "Discussions about budget, taxes, and economic policies",
      color: "#F59E0B"
    },
    %{
      name: "Healthcare",
      description: "Topics related to health policies, hospitals, and medical care",
      color: "#EF4444"
    }
  ],
  documents: [
    %{
      date: ~D[2024-04-25],
      title: "Sample Parliamentary Debate",
      content: """
      The parliament convened today to discuss important matters of state.
      The first topic was climate change. Many members expressed concern about rising temperatures.
      The second topic was education reform. Several proposals were put forward.
      Finally, the budget was discussed. The finance minister presented the annual report.
      """,
      excerpts: [
        %{
          category_name: "Climate Change",
          sentence_before: "The parliament convened today to discuss important matters of state.",
          sentence_with_keyword: "The first topic was climate change.",
          sentence_after: "Many members expressed concern about rising temperatures."
        },
        %{
          category_name: "Climate Change",
          sentence_before: "The first topic was climate change.",
          sentence_with_keyword: "Many members expressed concern about rising temperatures.",
          sentence_after: "The second topic was education reform."
        },
        %{
          category_name: "Economy",
          sentence_before: "Several proposals were put forward.",
          sentence_with_keyword: "Finally, the budget was discussed.",
          sentence_after: "The finance minister presented the annual report."
        }
      ]
    },
    %{
      date: ~D[2024-04-26],
      title: "Debate on Digital Infrastructure",
      content: """
      The parliament discussed the state of digital infrastructure in the country.
      Many rural areas still lack high-speed internet access.
      The minister proposed a new initiative to expand broadband coverage.
      Several members raised concerns about the timeline and budget.
      """,
      excerpts: [
        %{
          sentence_before:
            "The parliament discussed the state of digital infrastructure in the country.",
          sentence_with_keyword: "Many rural areas still lack high-speed internet access.",
          sentence_after: "The minister proposed a new initiative to expand broadband coverage."
        },
        %{
          sentence_before: "Many rural areas still lack high-speed internet access.",
          sentence_with_keyword:
            "The minister proposed a new initiative to expand broadband coverage.",
          sentence_after: "Several members raised concerns about the timeline and budget."
        },
        %{
          sentence_before: "The minister proposed a new initiative to expand broadband coverage.",
          sentence_with_keyword: "Several members raised concerns about the timeline and budget.",
          sentence_after: ""
        }
      ]
    },
    %{
      date: ~D[2024-04-27],
      title: "Discussion on Public Transportation",
      content: """
      Today's session focused on improving public transportation networks.
      The need for more sustainable transport options was emphasized.
      A new rail project connecting major cities was presented.
      Questions were raised about the environmental impact assessment.
      """,
      excerpts: [
        %{
          sentence_before: "Today's session focused on improving public transportation networks.",
          sentence_with_keyword:
            "The need for more sustainable transport options was emphasized.",
          sentence_after: "A new rail project connecting major cities was presented."
        },
        %{
          sentence_before: "The need for more sustainable transport options was emphasized.",
          sentence_with_keyword: "A new rail project connecting major cities was presented.",
          sentence_after: "Questions were raised about the environmental impact assessment."
        },
        %{
          sentence_before: "A new rail project connecting major cities was presented.",
          sentence_with_keyword:
            "Questions were raised about the environmental impact assessment.",
          sentence_after: ""
        }
      ]
    },
    %{
      date: ~D[2024-04-28],
      title: "Housing Policy Reform",
      content: """
      The housing crisis was the main topic of today's debate.
      Rising property prices were discussed at length.
      A new affordable housing initiative was proposed.
      Members debated the effectiveness of rent control measures.
      """,
      excerpts: [
        %{
          sentence_before: "The housing crisis was the main topic of today's debate.",
          sentence_with_keyword: "Rising property prices were discussed at length.",
          sentence_after: "A new affordable housing initiative was proposed."
        },
        %{
          sentence_before: "Rising property prices were discussed at length.",
          sentence_with_keyword: "A new affordable housing initiative was proposed.",
          sentence_after: "Members debated the effectiveness of rent control measures."
        },
        %{
          sentence_before: "A new affordable housing initiative was proposed.",
          sentence_with_keyword: "Members debated the effectiveness of rent control measures.",
          sentence_after: ""
        }
      ]
    },
    %{
      date: ~D[2024-04-29],
      title: "Foreign Policy Discussion",
      content: """
      The foreign minister presented the annual foreign policy report.
      Relations with neighboring countries were reviewed.
      Trade agreements and diplomatic missions were discussed.
      The opposition raised concerns about recent developments.
      """,
      excerpts: [
        %{
          sentence_before: "The foreign minister presented the annual foreign policy report.",
          sentence_with_keyword: "Relations with neighboring countries were reviewed.",
          sentence_after: "Trade agreements and diplomatic missions were discussed."
        },
        %{
          sentence_before: "Relations with neighboring countries were reviewed.",
          sentence_with_keyword: "Trade agreements and diplomatic missions were discussed.",
          sentence_after: "The opposition raised concerns about recent developments."
        },
        %{
          sentence_before: "Trade agreements and diplomatic missions were discussed.",
          sentence_with_keyword: "The opposition raised concerns about recent developments.",
          sentence_after: ""
        }
      ]
    },
    %{
      date: ~D[2024-04-30],
      title: "Social Welfare Reform",
      content: """
      The social welfare system was the focus of today's session.
      Proposed changes to pension schemes were debated.
      Support for low-income families was discussed.
      The minister outlined plans for a new social assistance program.
      """,
      excerpts: [
        %{
          sentence_before: "The social welfare system was the focus of today's session.",
          sentence_with_keyword: "Proposed changes to pension schemes were debated.",
          sentence_after: "Support for low-income families was discussed."
        },
        %{
          sentence_before: "Proposed changes to pension schemes were debated.",
          sentence_with_keyword: "Support for low-income families was discussed.",
          sentence_after: "The minister outlined plans for a new social assistance program."
        },
        %{
          sentence_before: "Support for low-income families was discussed.",
          sentence_with_keyword:
            "The minister outlined plans for a new social assistance program.",
          sentence_after: ""
        }
      ]
    }
  ]
}

# Create categories and collect their IDs
category_map =
  for category <- seed_data.categories do
    case SeedHelpers.create_or_find(Categories, category, :name) do
      nil -> {category.name, nil}
      created -> {category.name, created.category_id}
    end
  end
  |> Map.new()

IO.puts("Category map: #{inspect(category_map)}")

# Create documents and their excerpts
for doc_data <- seed_data.documents do
  case SeedHelpers.create_or_find(Documents, Map.drop(doc_data, [:excerpts]), :title) do
    nil ->
      IO.puts("Failed to create document: #{doc_data.title}")

    doc ->
      # Create excerpts for the document
      for excerpt_data <- doc_data.excerpts do
        excerpt_attrs =
          Map.merge(
            %{document_id: doc.document_id},
            case Map.get(excerpt_data, :category_name) do
              nil -> excerpt_data
              category_name -> Map.put(excerpt_data, :category_id, category_map[category_name])
            end
          )

        case Documents.create_excerpt(excerpt_attrs) do
          {:ok, created} ->
            IO.puts("Created excerpt with ID: #{created.excerpt_id}")

          {:error, error} ->
            IO.puts("Error creating excerpt: #{inspect(error)}")
        end
      end
  end
end
