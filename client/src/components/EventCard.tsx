import { useState } from "react";
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { CalendarDays, MapPin, Users, Clock } from "lucide-react";
import { Event, Volunteer } from "@/types";
import { api } from "@/lib/api";
import { useToast } from "@/hooks/use-toast";

interface EventCardProps {
  event: Event;
  volunteers: Volunteer[];
  onRsvpSuccess: () => void;
}

export const EventCard = ({ event, volunteers, onRsvpSuccess }: EventCardProps) => {
  const [selectedVolunteer, setSelectedVolunteer] = useState<string>("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const { toast } = useToast();

  const handleRsvp = async () => {
    if (!selectedVolunteer) {
      toast({
        title: "Please select a volunteer",
        variant: "destructive",
      });
      return;
    }

    setIsSubmitting(true);
    try {
      await api.rsvps.create({
        eventId: event.id,
        volunteerId: selectedVolunteer,
      });
      
      toast({
        title: "RSVP successful!",
        description: "Volunteer has been registered for this event.",
      });
      
      setSelectedVolunteer("");
      onRsvpSuccess();
    } catch (error) {
      toast({
        title: "RSVP failed",
        description: error instanceof Error ? error.message : "Something went wrong",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  return (
    <Card className="shadow-soft hover:shadow-medium transition-all duration-200 border-border/50">
      <CardHeader>
        <CardTitle className="text-xl text-primary">{event.title}</CardTitle>
        {event.description && (
          <p className="text-muted-foreground text-sm">{event.description}</p>
        )}
      </CardHeader>
      
      <CardContent className="space-y-4">
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <CalendarDays className="h-4 w-4" />
          <span>{formatDate(event.date)}</span>
        </div>
        
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <MapPin className="h-4 w-4" />
          <span>{event.city}</span>
        </div>
        
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <Users className="h-4 w-4" />
          <span>{event.slots} slots available</span>
        </div>
        
        {event.skills.length > 0 && (
          <div className="flex flex-wrap gap-2">
            {event.skills.map((skill, index) => (
              <Badge key={index} variant="secondary" className="text-xs">
                {skill}
              </Badge>
            ))}
          </div>
        )}
        
        <div className="space-y-2">
          <Select value={selectedVolunteer} onValueChange={setSelectedVolunteer}>
            <SelectTrigger>
              <SelectValue placeholder="Select a volunteer to RSVP" />
            </SelectTrigger>
            <SelectContent>
              {volunteers.map((volunteer) => (
                <SelectItem key={volunteer.id} value={volunteer.id}>
                  {volunteer.name} ({volunteer.city})
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </CardContent>
      
      <CardFooter>
        <Button 
          onClick={handleRsvp} 
          disabled={isSubmitting || !selectedVolunteer}
          className="w-full"
        >
          {isSubmitting ? (
            <div className="flex items-center gap-2">
              <Clock className="h-4 w-4 animate-spin" />
              Submitting RSVP...
            </div>
          ) : (
            "RSVP"
          )}
        </Button>
      </CardFooter>
    </Card>
  );
};