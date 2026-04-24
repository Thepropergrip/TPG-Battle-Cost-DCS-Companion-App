import sys
from pathlib import Path

import pandas as pd
import tkinter as tk
from tkinter import messagebox
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

# --------------------------------------------------
# Runtime paths
# --------------------------------------------------

def resource_path(relative_path: str) -> Path:
    base_path = Path(getattr(sys, "_MEIPASS", Path(__file__).resolve().parent))
    return base_path / relative_path


def find_logs() -> Path:
    saved = Path.home() / "Saved Games"
    for name in ("DCS", "DCS World", "DCS.openbeta", "DCS.openbeta_server"):
        p = saved / name / "Logs"
        if p.exists():
            return p
    return saved / "DCS" / "Logs"


def validate_assets() -> None:
    flags_dir = resource_path("flags")
    flags_zip = resource_path("flags.zip")

    if flags_dir.exists() or flags_zip.exists():
        return

    messagebox.showwarning(
        "TPG HUD - Missing assets",
        (
            "The map flag assets were not found.\n\n"
            "Expected either a 'flags' directory or 'flags.zip' beside the app."
        ),
    )

CSV = find_logs() / "TPG_LIVE.csv"

# --------------------------------------------------
# Window
# --------------------------------------------------

root = tk.Tk()
root.title("TPG HUD")

root.attributes("-topmost", True)
root.overrideredirect(True)
root.attributes("-alpha", 0.85)

root.geometry("+20+20")

# --------------------------------------------------
# HUD colors
# --------------------------------------------------

bg = "#000000"
border = bg   # SAME as background so border disappears
blue = "#4FC3F7"
red = "#FF5C5C"
txt = "#E6E6E6"

# --------------------------------------------------
# Border
# --------------------------------------------------

outer = tk.Frame(root, bg=border)
outer.pack(padx=2, pady=2)

frame = tk.Frame(outer, bg=bg)
frame.pack(padx=10, pady=8)

# --------------------------------------------------
# Title
# --------------------------------------------------

battle_total = tk.Label(
    frame,
    text="BATTLE TOTAL $0",
    fg=txt,
    bg=bg,
    font=("Consolas", 15, "bold"),
    anchor="w"
)
battle_total.grid(row=0, column=0, columnspan=3, sticky="w", pady=(0,12))

# --------------------------------------------------
# Headers
# --------------------------------------------------

tk.Label(frame, text="", bg=bg, width=14).grid(row=1, column=0)

tk.Label(frame,text="BLUE COALITION",fg=blue,bg=bg,font=("Consolas",13,"bold"),width=16).grid(row=1,column=1)

tk.Label(frame,text="RED COALITION",fg=red,bg=bg,font=("Consolas",13,"bold"),width=16).grid(row=1,column=2)

# --------------------------------------------------
# Metric labels
# --------------------------------------------------

tk.Label(frame,text="Cost Fired",fg=txt,bg=bg,font=("Consolas",12)).grid(row=2,column=0,sticky="w")
tk.Label(frame,text="Weapons",fg=txt,bg=bg,font=("Consolas",12)).grid(row=3,column=0,sticky="w")
tk.Label(frame,text="Losses",fg=txt,bg=bg,font=("Consolas",12)).grid(row=4,column=0,sticky="w")

# --------------------------------------------------
# Data
# --------------------------------------------------

cost_blue = tk.Label(frame,text="$0",fg=blue,bg=bg,font=("Consolas",12))
cost_blue.grid(row=2,column=1)

cost_red = tk.Label(frame,text="$0",fg=red,bg=bg,font=("Consolas",12))
cost_red.grid(row=2,column=2)

weap_blue = tk.Label(frame,text="0",fg=blue,bg=bg,font=("Consolas",12))
weap_blue.grid(row=3,column=1)

weap_red = tk.Label(frame,text="0",fg=red,bg=bg,font=("Consolas",12))
weap_red.grid(row=3,column=2)

loss_blue = tk.Label(frame,text="0",fg=blue,bg=bg,font=("Consolas",12))
loss_blue.grid(row=4,column=1)

loss_red = tk.Label(frame,text="0",fg=red,bg=bg,font=("Consolas",12))
loss_red.grid(row=4,column=2)

# --------------------------------------------------
# Percent
# --------------------------------------------------

blue_pct_label = tk.Label(frame,text="Blue Cost % 0%",fg=blue,bg=bg,font=("Consolas",12))
blue_pct_label.grid(row=5,column=0,columnspan=2,sticky="w",pady=(8,0))

red_pct_label = tk.Label(frame,text="Red Cost % 0%",fg=red,bg=bg,font=("Consolas",12))
red_pct_label.grid(row=5,column=2,sticky="e",pady=(8,0))

# --------------------------------------------------
# Chart (WIDER)
# --------------------------------------------------

fig = Figure(figsize=(5.8,1.2), dpi=100)   # was 3.2 — now fills width
ax = fig.add_subplot(111)

fig.patch.set_facecolor(bg)
ax.set_facecolor(bg)

ax.tick_params(left=False,bottom=False,labelleft=False,labelbottom=False)

for spine in ax.spines.values():
    spine.set_visible(False)

canvas = FigureCanvasTkAgg(fig,master=frame)
canvas_widget = canvas.get_tk_widget()
canvas_widget.grid(row=6,column=0,columnspan=3,pady=(10,0),sticky="ew")

# --------------------------------------------------
# CSV Reader
# --------------------------------------------------

def read_totals():

    if not CSV.exists():
        return 0,0,0,0,0,0,0,None

    try:

        df = pd.read_csv(CSV)

        totals = df[df["row_type"]=="TOTAL"]

        if totals.empty:
            return 0,0,0,0,0,0,0,None

        latest = totals["time"].max()
        t = totals[totals["time"]==latest]

        blue_cost=float(t[t["side"]=="BLUE"]["total_cost"].iloc[0]) if not t[t["side"]=="BLUE"].empty else 0
        red_cost=float(t[t["side"]=="RED"]["total_cost"].iloc[0]) if not t[t["side"]=="RED"].empty else 0

        total = blue_cost+red_cost

        items=df[df["row_type"]=="ITEM"]
        items=items[items["time"]==latest]

        blue=items[items["side"]=="BLUE"]
        red=items[items["side"]=="RED"]

        blue_weapons=int(blue[blue["event"]=="FIRED"]["count"].sum())
        red_weapons=int(red[red["event"]=="FIRED"]["count"].sum())

        blue_losses=int(blue[blue["event"]=="LOSS"]["count"].sum())
        red_losses=int(red[red["event"]=="LOSS"]["count"].sum())

        return total,blue_cost,red_cost,blue_weapons,red_weapons,blue_losses,red_losses,df

    except Exception:
        return 0,0,0,0,0,0,0,None

# --------------------------------------------------
# Chart update
# --------------------------------------------------

def update_chart(df):

    if df is None:
        return

    totals=df[df["row_type"]=="TOTAL"]

    if totals.empty:
        return

    blue_series=totals[totals["side"]=="BLUE"]
    red_series=totals[totals["side"]=="RED"]

    ax.clear()
    ax.set_facecolor(bg)

    ax.plot(blue_series["time"],blue_series["total_cost"],color=blue,linewidth=2)
    ax.plot(red_series["time"],red_series["total_cost"],color=red,linewidth=2)

    ax.tick_params(left=False,bottom=False,labelleft=False,labelbottom=False)

    for spine in ax.spines.values():
        spine.set_visible(False)

    canvas.draw()

# --------------------------------------------------
# Update loop
# --------------------------------------------------

def update():

    total,blue_cost,red_cost,bw,rw,bl,rl,df=read_totals()

    blue_pct=(blue_cost/total*100) if total>0 else 0
    red_pct=(red_cost/total*100) if total>0 else 0

    battle_total.config(text=f"BATTLE TOTAL  ${total:,.0f}")

    cost_blue.config(text=f"${blue_cost:,.0f}")
    cost_red.config(text=f"${red_cost:,.0f}")

    weap_blue.config(text=str(bw))
    weap_red.config(text=str(rw))

    loss_blue.config(text=str(bl))
    loss_red.config(text=str(rl))

    blue_pct_label.config(text=f"Blue Cost % {blue_pct:,.1f}%")
    red_pct_label.config(text=f"Red Cost % {red_pct:,.1f}%")

    update_chart(df)

    root.after(1000,update)

# --------------------------------------------------
# Dragging
# --------------------------------------------------

def start_move(e):
    root.x=e.x
    root.y=e.y

def move(e):
    root.geometry(f"+{e.x_root-root.x}+{e.y_root-root.y}")

def bind_drag(widget):
    widget.bind("<ButtonPress-1>",start_move)
    widget.bind("<B1-Motion>",move)

for w in [root, outer, frame,
          battle_total, cost_blue, cost_red,
          weap_blue, weap_red, loss_blue, loss_red,
          blue_pct_label, red_pct_label, canvas_widget]:
    bind_drag(w)

# --------------------------------------------------

validate_assets()
update()
root.mainloop()
