import { CreateEventForm } from "@/components/CreateEventForm";
import { Calendar, ArrowLeft } from "lucide-react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";

export default function CreateEvent() {
  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Button asChild variant="outline" size="sm">
          <Link to="/events" className="flex items-center gap-2">
            <ArrowLeft className="h-4 w-4" />
            Back to Events
          </Link>
        </Button>
        
        <div>
          <h1 className="text-4xl font-bold text-foreground flex items-center gap-3">
            <Calendar className="h-8 w-8 text-primary" />
            Create New Event
          </h1>
          <p className="text-muted-foreground text-lg mt-2">
            Post a new volunteer opportunity for your community
          </p>
        </div>
      </div>

      {/* Form */}
      <CreateEventForm />
    </div>
  );
}