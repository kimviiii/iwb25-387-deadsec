type ID = string;

export interface Event {
  id: ID;
  title: string;
  description?: string;
  date: string;
  location: string;
  skills: string[];
  slots: number;
  createdAt?: string;
}

export interface Volunteer {
  id: ID;
  name: string;
  email?: string;
  location: string;
  skills: string[];
  availability: string;
  createdAt?: string;
}

export interface Rsvp {
  id: ID;
  eventId: ID;
  volunteerId: ID;
  createdAt?: string;
}

export interface MatchResult {
  eventId: string;
  title: string;
  score: number;
  why: string;
}