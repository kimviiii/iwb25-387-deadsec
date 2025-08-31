import { EventCard } from "./EventCard";
import { Event, Volunteer } from "@/types";

interface EventListProps {
  events: Event[];
  volunteers: Volunteer[];
  onRsvpSuccess: () => void;
}

export const EventList = ({ events, volunteers, onRsvpSuccess }: EventListProps) => {
  if (events.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-muted-foreground text-lg">No events found</p>
        <p className="text-muted-foreground text-sm">Check back later for new volunteer opportunities!</p>
      </div>
    );
  }

  return (
    <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
      {events.map((event) => (
        <EventCard
          key={event.id}
          event={event}
          volunteers={volunteers}
          onRsvpSuccess={onRsvpSuccess}
        />
      ))}
    </div>
  );
};