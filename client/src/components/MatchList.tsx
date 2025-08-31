import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { CalendarDays, MapPin, Users, BarChart3, TrendingUp } from "lucide-react";
import { MatchResult, Volunteer } from "@/types";
import { api } from "@/lib/api";
import { useToast } from "@/hooks/use-toast";

interface MatchListProps {
  volunteers: Volunteer[];
}

export const MatchList = ({ volunteers }: MatchListProps) => {
  const [selectedVolunteer, setSelectedVolunteer] = useState<string>("");
  const [matches, setMatches] = useState<MatchResult[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const { toast } = useToast();

  const fetchMatches = async (volunteerId: string) => {
    setIsLoading(true);
    try {
      const matchResults = await api.match(volunteerId) as MatchResult[];
      setMatches(matchResults);
    } catch (error) {
      toast({
        title: "Failed to fetch matches",
        description: error instanceof Error ? error.message : "Something went wrong",
        variant: "destructive",
      });
      setMatches([]);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (selectedVolunteer) {
      fetchMatches(selectedVolunteer);
    } else {
      setMatches([]);
    }
  }, [selectedVolunteer]);

  const getScoreColor = (score: number) => {
    if (score >= 80) return "text-success";
    if (score >= 60) return "text-secondary";
    if (score >= 40) return "text-primary";
    return "text-muted-foreground";
  };

  const getScoreBadgeVariant = (score: number) => {
    if (score >= 80) return "default";
    if (score >= 60) return "secondary";
    return "outline";
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      weekday: 'short',
      month: 'short',
      day: 'numeric',
    });
  };

  return (
    <div className="space-y-6">
      <Card className="shadow-soft">
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-primary">
            <BarChart3 className="h-6 w-6" />
            Volunteer Matching
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div>
              <label className="text-sm font-medium mb-2 block">Select Volunteer</label>
              <Select value={selectedVolunteer} onValueChange={setSelectedVolunteer}>
                <SelectTrigger>
                  <SelectValue placeholder="Choose a volunteer to see matches" />
                </SelectTrigger>
                <SelectContent>
                  {volunteers.map((volunteer) => (
                    <SelectItem key={volunteer.id} value={volunteer.id}>
                      <div className="flex flex-col">
                        <span>{volunteer.name}</span>
                        <span className="text-xs text-muted-foreground">
                          {volunteer.city} • {volunteer.skills.length} skills
                        </span>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {selectedVolunteer && (
              <div className="pt-4 border-t">
                <div className="flex items-center gap-2 mb-4">
                  <TrendingUp className="h-5 w-5 text-primary" />
                  <span className="font-medium">
                    {isLoading ? "Finding matches..." : `Found ${matches.length} matches`}
                  </span>
                </div>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {isLoading && (
        <div className="text-center py-12">
          <div className="animate-spin mx-auto h-8 w-8 border-4 border-primary border-t-transparent rounded-full"></div>
          <p className="text-muted-foreground mt-4">Finding the best matches...</p>
        </div>
      )}

      {!isLoading && matches.length === 0 && selectedVolunteer && (
        <div className="text-center py-12">
          <p className="text-muted-foreground text-lg">No matches found</p>
          <p className="text-muted-foreground text-sm">Try selecting a different volunteer or check back later for new events.</p>
        </div>
      )}

      {!isLoading && matches.length > 0 && (
        <div className="space-y-4">
          <h3 className="text-xl font-semibold text-foreground">
            Recommended Events (Ranked by Match Score)
          </h3>
          <div className="space-y-4">
            {matches.map((match, index) => (
              <Card key={match.event.id} className="shadow-soft border-border/50">
                <CardContent className="p-6">
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex-1">
                      <div className="flex items-start gap-3">
                        <div className="flex-1">
                          <h4 className="text-lg font-semibold text-primary mb-2">
                            {match.event.title}
                          </h4>
                          {match.event.description && (
                            <p className="text-muted-foreground text-sm mb-3">
                              {match.event.description}
                            </p>
                          )}
                        </div>
                        <div className="text-right">
                          <Badge 
                            variant={getScoreBadgeVariant(match.score)}
                            className={`text-sm font-bold ${getScoreColor(match.score)}`}
                          >
                            {match.score}% Match
                          </Badge>
                          <div className="text-xs text-muted-foreground mt-1">
                            Rank #{index + 1}
                          </div>
                        </div>
                      </div>
                      
                      <div className="grid md:grid-cols-3 gap-4 mb-4">
                        <div className="flex items-center gap-2 text-sm text-muted-foreground">
                          <CalendarDays className="h-4 w-4" />
                          <span>{formatDate(match.event.date)}</span>
                        </div>
                        
                        <div className="flex items-center gap-2 text-sm text-muted-foreground">
                          <MapPin className="h-4 w-4" />
                          <span>{match.event.city}</span>
                        </div>
                        
                        <div className="flex items-center gap-2 text-sm text-muted-foreground">
                          <Users className="h-4 w-4" />
                          <span>{match.event.slots} slots</span>
                        </div>
                      </div>

                      {match.event.skills.length > 0 && (
                        <div className="mb-4">
                          <div className="text-sm font-medium mb-2">Required Skills:</div>
                          <div className="flex flex-wrap gap-2">
                            {match.event.skills.map((skill, skillIndex) => (
                              <Badge key={skillIndex} variant="outline" className="text-xs">
                                {skill}
                              </Badge>
                            ))}
                          </div>
                        </div>
                      )}

                      {match.why.length > 0 && (
                        <div>
                          <div className="text-sm font-medium mb-2">Why this is a good match:</div>
                          <div className="flex flex-wrap gap-2">
                            {match.why.map((reason, reasonIndex) => (
                              <Badge key={reasonIndex} variant="secondary" className="text-xs">
                                {reason}
                              </Badge>
                            ))}
                          </div>
                        </div>
                      )}
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};