# 45. Calendar

The **Calendar** keeps your appointments and To Do items, reminds you of them, and exchanges them with the Mailer and other calendar programs. It is the CDE Calendar, with its four views, its Appointment Editor and its reminders, stored in the standard iCalendar format.

Click the **Calendar** in the Front Panel, which shows today's date, or start `amade-calendar`.

![The Calendar in Month view](images/45/calendar.jpg)

## The views

The buttons **Day**, **Week**, **Month** and **Year** in the tool bar switch the view; **◀**, **Today** and **▶** step back and forward by a day, a week, a month or a year. *View → Go To Date…* jumps anywhere.

| View | What it shows |
|---|---|
| **Day** | The day hour by hour, with a small calendar of three months beside it. Days with appointments are bold there. |
| **Week** | A column for each day with its appointments, and below a grid of the week with the taken hours shaded. |
| **Month** | The month with the appointments in the day boxes. |
| **Year** | The twelve months. A click on a month or a day opens it. |

## Appointments

**Double-click a day**, or an hour in the Day view, to open the **Appointment Editor** for it; double-click an appointment to change it. Enter the **Date**, **Start** and **End**, and in **What** what it is about; the first line is what the views show. Leave *Start* empty for an appointment without a time, such as a birthday. Then click **Insert**. **Change** saves changes to the selected appointment, **Delete** removes it.

The small calendar button next to each date field opens a date chooser.

**More** shows the rest:

- **Reminders**: *Beep*, *Flash* (the Calendar window draws attention), *Popup* (a message) and *Mail* (a message to yourself, ready to send in the Mailer), each a chosen time before the appointment.
- **Occurs**: once, daily, weekly, every two weeks, monthly by date or by weekday, yearly, Monday to Friday and more, with **For** the number of times (empty for ever). When you change or delete one appointment of a series, the Calendar asks whether you mean *This One*, *Forward* (this one and all later ones) or *All*.
- **Privacy**: what others may see when the calendar is printed for them: time and text, the time only, or nothing.

Reminders appear while the Calendar runs, so leave it open, on another workspace if you like.

## To Do items

*Edit → To Do…* (or **To Do** in the tool bar) opens the To Do Editor: a due date, a description and *Completed*. *View → To Do List…* lists them with a check box each, and can show all, the pending or the completed ones.

## Finding and listing

*View → Find…* searches the text of the appointments, six months back and ahead, or with *Search all* the whole calendar. *View → Appointment List…* lists the appointments of the view's period in a table.

## With the Mailer and other calendars

- An **`.ics` file**, from a mail attachment, the File Manager or another calendar program, opens in the Calendar and its appointments are added. Files can also be dropped on the Calendar window.
- In a mail with an appointment, **Schedule in Calendar** adds it.
- In the Appointment Editor, **Mail…** opens the Mailer with the appointment as the message, and the **Drag Appointment** icon carries the appointment out to the File Manager or a mail as an `.ics` file.

An export of your Google Calendar opens without losses: repeating appointments with their exceptions, appointments spanning several days and times in other time zones.

## Printing

*File → Print Current View* (++ctrl+p++) prints what is on the screen. *File → Print…* chooses what to print, day, week, month or year, the appointment list or the To Do list, the dates and the number of copies.

## Options

*File → Options…* has a *Category* menu: **Editor Defaults** for new appointments, **Display Settings** (the hours of the Day and Week views, 12- or 24-hour time, the view to start with), **Date Format**, **Printer Settings** and **Language**.

!!! planned "Planned"
    One place for all your accounts, shared by the Mailer and the Calendar; showing other calendars next to your own (Google, Nextcloud and other CalDAV servers); keeping your calendar in step with a server both ways, which also lets you share a calendar with another person.

??? hood "Under the hood"
    The whole calendar is one iCalendar file (RFC 5545), `~/.local/share/amadeos/calendar/calendar.ics`, the options are in `~/.config/amadeos/calendar/calendar.conf`. What the Calendar does not know itself, such as places or attendees from other programs, it keeps and writes back unchanged.
