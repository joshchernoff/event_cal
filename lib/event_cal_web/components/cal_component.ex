defmodule EventCalWeb.CalComponent do
  use Phoenix.Component

  def cal(assigns) do
    ~H"""
    <section class="even:hidden even:md:block text-center md:block">
      <h2 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100">{@month} {@year}</h2>
      <div class="mt-8 grid grid-cols-7 text-xs/6 text-zinc-500">
        <div>Sun</div>
        <div>Mon</div>
        <div>Tue</div>
        <div>Wed</div>
        <div>Thu</div>
        <div>Fri</div>
        <div>Sat</div>
      </div>
      <div class="isolate mt-4 grid grid-cols-7 gap-px bg-zinc-200 dark:bg-zinc-800 text-xs shadow ring-1 ring-zinc-200 dark:ring-zinc-800 shadow-xl">
        <button
          :for={{scope, date} <- @cal}
          type="button"
          class={
            (scope == :outside &&
               "relative bg-zinc-100 dark:bg-zinc-900/10 py-1.5 text-zinc-300 dark:text-zinc-700 hover:bg-zinc-100 dark:hover:bg-zinc-800 focus:z-10") ||
              "relative bg-white dark:bg-zinc-900 py-1.5 text-zinc-900 dark:text-zinc-100 hover:bg-zinc-100 dark:hover:bg-zinc-800 focus:z-10"
          }
        >
          <span class="mx-auto flex size-7 items-center justify-center rounded-full">
            <span
              :if={scope == :today}
              class="animate-ping absolute inline-flex h-4 w-4 rounded-full bg-sky-400 opacity-75"
            >
            </span>
            {date}
          </span>
        </button>
      </div>
    </section>
    """
  end
end
