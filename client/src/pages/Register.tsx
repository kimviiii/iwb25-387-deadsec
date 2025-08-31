import { VolunteerForm } from "@/components/VolunteerForm";
import { Users, ArrowLeft } from "lucide-react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";

export default function Register() {
  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Button asChild variant="outline" size="sm">
          <Link to="/" className="flex items-center gap-2">
            <ArrowLeft className="h-4 w-4" />
            Back to Home
          </Link>
        </Button>
        
        <div>
          <h1 className="text-4xl font-bold text-foreground flex items-center gap-3">
            <Users className="h-8 w-8 text-secondary" />
            Join as Volunteer
          </h1>
          <p className="text-muted-foreground text-lg mt-2">
            Register to start making a difference in your community
          </p>
        </div>
      </div>

      {/* Form */}
      <VolunteerForm />
    </div>
  );
}