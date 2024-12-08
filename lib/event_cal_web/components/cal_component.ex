defmodule EventCalWeb.CalComponent do
  use Phoenix.Component

  def cal(assigns) do
    ~H"""
    <section class="even:hidden even:md:block text-center md:block">
      <h2 class="text-sm font-semibold text-zinc-900">{@month} {@year}</h2>
      <div class="mt-8 grid grid-cols-7 text-xs/6 text-zinc-500">
        <div>Sun</div>
        <div>Mon</div>
        <div>Tue</div>
        <div>Wed</div>
        <div>Thu</div>
        <div>Fri</div>
        <div>Sat</div>
      </div>
      <div class="isolate mt-4 grid grid-cols-7 gap-px bg-zinc-200 text-xs shadow ring-1 ring-zinc-200 shadow-xl">
        <button
          :for={{scope, date} <- @cal}
          type="button"
          class={[
            scope == :outside &&
              "relative bg-zinc-100 py-1.5 text-zinc-300 hover:bg-zinc-100 focus:z-10",
            scope == :inside &&
              "relative bg-white py-1.5 text-zinc-900 hover:bg-zinc-100 focus:z-10"
          ]}
        >
          <span class="mx-auto flex size-7 items-center justify-center rounded-full">
            {date}
          </span>
        </button>
      </div>
    </section>
    """
  end
end
