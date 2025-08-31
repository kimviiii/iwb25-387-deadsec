import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { EventList } from "@/components/EventList";
import { Calendar, Plus, RefreshCw } from "lucide-react";
import { Event, Volunteer } from "@/types";
import { api } from "@/lib/api";
import { useToast } from "@/hooks/use-toast";

export default function Events() {
  const [events, setEvents] = useState<Event[]>([]);
  const [volunteers, setVolunteers] = useState<Volunteer[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const { toast } = useToast();

  const fetchData = async () => {
    setIsLoading(true);
    try {
      const [eventsData, volunteersData] = await Promise.all([
        api.events.list() as Promise<Event[]>,
        api.volunteers.list() as Promise<Volunteer[]>,
      ]);
      setEvents(eventsData);
      setVolunteers(volunteersData);
    } catch (error) {
      toast({
        title: "Failed to load data",
        description: error instanceof Error ? error.message : "Something went wrong",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleRsvpSuccess = () => {
    toast({
      title: "RSVP confirmed!",
      description: "The volunteer has been successfully registered for the event.",
    });
    // Optionally refresh data
    fetchData();
  };

  if (isLoading) {
    return (
      <div className="text-center py-12">
        <div className="animate-spin mx-auto h-12 w-12 border-4 border-primary border-t-transparent rounded-full"></div>
        <p className="text-muted-foreground mt-4 text-lg">Loading events...</p>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-4xl font-bold text-foreground flex items-center gap-3">
            <Calendar className="h-8 w-8 text-primary" />
            Volunteer Events
          </h1>
          <p className="text-muted-foreground text-lg mt-2">
            Discover meaningful volunteer opportunities in your community
          </p>
        </div>
        
        <div className="flex gap-3">
          <Button 
            variant="outline" 
            onClick={fetchData}
            disabled={isLoading}
            className="flex items-center gap-2"
          >
            <RefreshCw className={`h-4 w-4 ${isLoading ? 'animate-spin' : ''}`} />
            Refresh
          </Button>
          
          <Button asChild className="flex items-center gap-2">
            <Link to="/create-event">
              <Plus className="h-4 w-4" />
              Create Event
            </Link>
          </Button>
        </div>
      </div>

      {/* Events Count */}
      <div className="bg-card border rounded-lg p-4 shadow-soft">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="font-semibold text-lg">Available Events</h3>
            <p className="text-muted-foreground">
              {events.length} {events.length === 1 ? 'event' : 'events'} • {volunteers.length} registered volunteers
            </p>
          </div>
          {volunteers.length === 0 && (
            <Button asChild variant="secondary" size="sm">
              <Link to="/register" className="flex items-center gap-2">
                <Plus className="h-4 w-4" />
                Register First Volunteer
              </Link>
            </Button>
          )}
        </div>
      </div>

      {/* Events List */}
      <EventList 
        events={events} 
        volunteers={volunteers} 
        onRsvpSuccess={handleRsvpSuccess} 
      />

      {/* Empty State Actions */}
      {events.length === 0 && (
        <div className="text-center py-12">
          <Calendar className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
          <h3 className="text-xl font-semibold mb-2">No events yet</h3>
          <p className="text-muted-foreground mb-6">
            Get started by creating the first volunteer event!
          </p>
          <Button asChild>
            <Link to="/create-event" className="flex items-center gap-2">
              <Plus className="h-4 w-4" />
              Create First Event
            </Link>
          </Button>
        </div>
      )}
    </div>
  );
}