import { useState, useEffect } from "react";
import { MatchList } from "@/components/MatchList";
import { BarChart3, ArrowLeft } from "lucide-react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Volunteer } from "@/types";
import { api } from "@/lib/api";
import { useToast } from "@/hooks/use-toast";

export default function Matches() {
  const [volunteers, setVolunteers] = useState<Volunteer[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const { toast } = useToast();

  useEffect(() => {
    fetchVolunteers();
  }, []);

  const fetchVolunteers = async () => {
    setIsLoading(true);
    try {
      const volunteersData = await api.volunteers.list() as Volunteer[];
      setVolunteers(volunteersData);
    } catch (error) {
      toast({
        title: "Failed to load volunteers",
        description: error instanceof Error ? error.message : "Something went wrong",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="text-center py-12">
        <div className="animate-spin mx-auto h-12 w-12 border-4 border-primary border-t-transparent rounded-full"></div>
        <p className="text-muted-foreground mt-4 text-lg">Loading volunteers...</p>
      </div>
    );
  }

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
            <BarChart3 className="h-8 w-8 text-primary" />
            Volunteer Matching
          </h1>
          <p className="text-muted-foreground text-lg mt-2">
            Find the perfect events for each volunteer using our smart matching algorithm
          </p>
        </div>
      </div>

      {/* Matches */}
      {volunteers.length === 0 ? (
        <div className="text-center py-12">
          <BarChart3 className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
          <h3 className="text-xl font-semibold mb-2">No volunteers registered</h3>
          <p className="text-muted-foreground mb-6">
            Register some volunteers first to see match recommendations!
          </p>
          <Button asChild>
            <Link to="/register">Register First Volunteer</Link>
          </Button>
        </div>
      ) : (
        <MatchList volunteers={volunteers} />
      )}
    </div>
  );
}