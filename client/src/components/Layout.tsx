import { Link, useLocation } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Heart, Calendar, Users, Plus, BarChart3 } from "lucide-react";
import Footer from "./ui/Footer";

export const Layout = ({ children }: { children: React.ReactNode }) => {
  const location = useLocation();
  
  const isActive = (path: string) => location.pathname === path;

  const showFooterPages = ["/events", "/matches", "/register","/",];

  
  return (
    <div className="min-h-screen bg-gradient-subtle flex flex-col">
      <header className="border-b bg-card/50 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <Link to="/" className="flex items-center gap-2 text-primary font-bold text-xl">
              <Heart className="h-6 w-6" />
              VoluntHere
            </Link>
            
            <nav className="hidden md:flex gap-4">
              <Button 
                asChild 
                variant={isActive('/') ? 'default' : 'ghost'}
                size="sm"
              >
                <Link to="/">Home</Link>
              </Button>
              
              <Button 
                asChild 
                variant={isActive('/events') ? 'default' : 'ghost'}
                size="sm"
              >
                <Link to="/events" className="flex items-center gap-2">
                  <Calendar className="h-4 w-4" />
                  Events
                </Link>
              </Button>
              
              <Button 
                asChild 
                variant={isActive('/matches') ? 'default' : 'ghost'}
                size="sm"
              >
                <Link to="/matches" className="flex items-center gap-2">
                  <BarChart3 className="h-4 w-4" />
                  Matches
                </Link>
              </Button>
              
              <Button 
                asChild 
                variant={isActive('/create-event') ? 'secondary' : 'outline'}
                size="sm"
              >
                <Link to="/create-event" className="flex items-center gap-2">
                  <Plus className="h-4 w-4" />
                  Create Event
                </Link>
              </Button>
              
              <Button 
                asChild 
                variant={isActive('/register') ? 'secondary' : 'outline'}
                size="sm"
              >
                <Link to="/register" className="flex items-center gap-2">
                  <Users className="h-4 w-4" />
                  Register
                </Link>
              </Button>
            </nav>
          </div>
        </div>
      </header>
      
      <main className="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">
        {children}
      </main>

      {/* FOOTER (only on selected pages) */}
      {showFooterPages.includes(location.pathname) && <Footer />}

    </div>
  );
};