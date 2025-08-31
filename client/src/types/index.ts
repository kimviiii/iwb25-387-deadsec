type ID = string;

export interface Event {
  id: ID;
  title: string;
  description?: string;
  date: string;
  city: string;
  skills: string[];
  slots: number;
  createdAt?: string;
}

export interface Volunteer {
  id: ID;
  name: string;
  email?: string;
  city: string;
  skills: string[];
  createdAt?: string;
}

export interface Rsvp {
  id: ID;
  eventId: ID;
  volunteerId: ID;
  createdAt?: string;
}

export interface MatchResult {
  event: Event;
  score: number;
  why: string[];
}