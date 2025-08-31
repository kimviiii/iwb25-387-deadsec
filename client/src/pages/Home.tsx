import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Heart, Calendar, Users, Plus, BarChart3, CheckCircle, XCircle, Activity } from "lucide-react";
import { api } from "@/lib/api";
import { useToast } from "@/hooks/use-toast";

export default function Home() {
  const [healthStatus, setHealthStatus] = useState<'loading' | 'healthy' | 'error'>('loading');
  const { toast } = useToast();

  useEffect(() => {
    checkHealth();
  }, []);

  const checkHealth = async () => {
    try {
      await api.health();
      setHealthStatus('healthy');
    } catch (error) {
      setHealthStatus('error');
      toast({
        title: "Backend connection failed",
        description: "Make sure the backend server is running on localhost:8090",
        variant: "destructive",
      });
    }
  };

  return (
    <div className="space-y-12">
      {/* Hero Section */}
      <section className="text-center py-16 bg-gradient-primary rounded-lg text-white relative overflow-hidden">
        <div className="relative z-10 py-13">
          <h1 className="text-5xl font-bold mb-6">
            Welcome to VoluntHere
          </h1>
          <p className="text-xl mb-8 text-white/90 max-w-2xl mx-auto">
            Connect passionate volunteers with meaningful opportunities in your community. 
            Make a difference, one event at a time.
          </p>
          <div className="flex gap-4 justify-center flex-wrap">
            <Button asChild size="lg" variant="secondary">
              <Link to="/events" className="flex items-center gap-2">
                <Calendar className="h-5 w-5" />
                Browse Events
              </Link>
            </Button>
            <Button asChild size="lg" variant="outline" className="bg-white/10 text-white border-white/30 hover:bg-white/20">
              <Link to="/register" className="flex items-center gap-2">
                <Users className="h-5 w-5" />
                Join as Volunteer
              </Link>
            </Button>
          </div>
        </div>
      </section>

      {/* System Status */}
      <section>
        <Card className="shadow-soft">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Activity className="h-5 w-5 text-primary" />
              System Status
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-3">
              {healthStatus === 'loading' && (
                <>
                  <div className="animate-spin h-5 w-5 border-2 border-primary border-t-transparent rounded-full"></div>
                  <span className="text-muted-foreground">Checking backend connection...</span>
                </>
              )}
              {healthStatus === 'healthy' && (
                <>
                  <CheckCircle className="h-5 w-5 text-success" />
                  <span className="text-success font-medium">Backend is healthy</span>
                  <Badge variant="outline" className="ml-auto">
                    Connected to localhost:8090
                  </Badge>
                </>
              )}
              {healthStatus === 'error' && (
                <>
                  <XCircle className="h-5 w-5 text-destructive" />
                  <span className="text-destructive font-medium">Backend connection failed</span>
                  <Button 
                    variant="outline" 
                    size="sm" 
                    onClick={checkHealth}
                    className="ml-auto"
                  >
                    Retry
                  </Button>
                </>
              )}
            </div>
          </CardContent>
        </Card>
      </section>

      {/* Quick Actions */}
      <section>
        <h2 className="text-3xl font-bold text-center mb-8 text-foreground">
          Quick Actions
        </h2>
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          <Card className="shadow-soft hover:shadow-medium transition-all duration-200 group">
            <CardHeader className="text-center">
              <Calendar className="h-12 w-12 mx-auto text-primary group-hover:scale-110 transition-transform" />
              <CardTitle>View Events</CardTitle>
              <CardDescription>
                Browse all available volunteer opportunities
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Button asChild className="w-full">
                <Link to="/events">Browse Events</Link>
              </Button>
            </CardContent>
          </Card>

          <Card className="shadow-soft hover:shadow-medium transition-all duration-200 group">
            <CardHeader className="text-center">
              <BarChart3 className="h-12 w-12 mx-auto text-secondary group-hover:scale-110 transition-transform" />
              <CardTitle>Find Matches</CardTitle>
              <CardDescription>
                Discover the best events for each volunteer
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Button asChild variant="secondary" className="w-full">
                <Link to="/matches">View Matches</Link>
              </Button>
            </CardContent>
          </Card>

          <Card className="shadow-soft hover:shadow-medium transition-all duration-200 group">
            <CardHeader className="text-center">
              <Plus className="h-12 w-12 mx-auto text-primary group-hover:scale-110 transition-transform" />
              <CardTitle>Create Event</CardTitle>
              <CardDescription>
                Post a new volunteer opportunity
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Button asChild variant="outline" className="w-full">
                <Link to="/create-event">Create Event</Link>
              </Button>
            </CardContent>
          </Card>

          <Card className="shadow-soft hover:shadow-medium transition-all duration-200 group">
            <CardHeader className="text-center">
              <Users className="h-12 w-12 mx-auto text-secondary group-hover:scale-110 transition-transform" />
              <CardTitle>Register</CardTitle>
              <CardDescription>
                Join our community of volunteers
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Button asChild variant="outline" className="w-full">
                <Link to="/register">Register Now</Link>
              </Button>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* Features */}
      <section className="text-center">
        <h2 className="text-3xl font-bold mb-8 text-foreground">
          How VoluntHere Works
        </h2>
        <div className="grid md:grid-cols-3 gap-8">
          <div className="space-y-4">
            <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto">
              <Users className="h-8 w-8 text-primary" />
            </div>
            <h3 className="text-xl font-semibold">1. Register</h3>
            <p className="text-muted-foreground">
              Sign up as a volunteer with your skills and location
            </p>
          </div>
          
          <div className="space-y-4">
            <div className="w-16 h-16 bg-secondary/10 rounded-full flex items-center justify-center mx-auto">
              <BarChart3 className="h-8 w-8 text-secondary" />
            </div>
            <h3 className="text-xl font-semibold">2. Get Matched</h3>
            <p className="text-muted-foreground">
              Our smart matching system finds the perfect events for you
            </p>
          </div>
          
          <div className="space-y-4">
            <div className="w-16 h-16 bg-success/10 rounded-full flex items-center justify-center mx-auto">
              <Heart className="h-8 w-8 text-success" />
            </div>
            <h3 className="text-xl font-semibold">3. Make Impact</h3>
            <p className="text-muted-foreground">
              Join events and make a positive difference in your community
            </p>
          </div>
        </div>
      </section>
    </div>
  );
}